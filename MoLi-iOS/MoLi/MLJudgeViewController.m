//
//  MLJudgeViewController.m
//  MoLi
//
//  Created by 颜超 on 15/4/16.
//  Copyright (c) 2015年 zoombin. All rights reserved.
//

#import "MLJudgeViewController.h"
#import "MLGoodsOrderTableViewCell.h"

@interface MLJudgeViewController ()

@end

@implementation MLJudgeViewController {
    NSArray *goodsArray;
    NSMutableArray *imagePaths;
    NSString *star;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor backgroundColor];
    self.title = @"评价订单";
    star = @"5";
    [self setLeftBarButtonItemAsBackArrowButton];
    _commentTextView.backgroundColor = [UIColor backgroundColor];
    _commentTextView.delegate = self;
    [_commentTextView.layer setCornerRadius:4.0];
    [_commentTextView.layer setMasksToBounds:YES];
    imagePaths = [NSMutableArray array];
    [_tableView setTableFooterView:_footView];
    [self showInfo];
}

- (IBAction)starButtonClicked:(id)sender {
    NSArray *btns = @[_star1, _star2, _star3, _star4, _star5];
    star = [NSString stringWithFormat:@"%d", [sender tag]];
    for (int i = 0; i < [btns count]; i++) {
        UIButton *btn = btns[i];
        if (i < [sender tag]) {
             btn.selected = YES;
        } else {
            btn.selected = NO;
        }
    }
}

- (void)selectPhoto:(id)sender {
    if ([sender tag] - 1000 <=  [imagePaths count]) {
        [imagePaths removeObjectAtIndex:[sender tag] - 1001];
        [self refreshButton];
    } else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"拍照", nil), NSLocalizedString(@"从相册选取", nil), nil];
        [actionSheet showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.cancelButtonIndex == buttonIndex) {
        return;
    }
    if (actionSheet.firstOtherButtonIndex == buttonIndex) {
        NSLog(@"拍照");
        [self takePhoto];
    } else if (actionSheet.firstOtherButtonIndex + 1 == buttonIndex) {
        NSLog(@"从相册获取");
        [self LocalPhoto];
    }
}

- (void)uploadImage:(UIImage *)img {
    [self displayHUD:@"上传中..."];
    [[MLAPIClient shared] uploadImage:img withBlock:^(NSString *imagePath, MLResponse *response) {
        [self displayResponseMessage:response];
        if (response.success) {
            NSLog(@"上传成功");
            NSMutableDictionary *imgDict = [[NSMutableDictionary alloc] init];
            imgDict[@"img"] = img;
            imgDict[@"url"] = imagePath;
            [imagePaths addObject:imgDict];
            [self refreshButton];
        }
    }];
}

- (void)refreshButton {
    if ([imagePaths count] == 0) {
        [_photo1 setBackgroundImage:[UIImage imageNamed:@"afterSaleAdd"] forState:UIControlStateNormal];
        _photo2.hidden = YES;
        _photo3.hidden = YES;
    }
    if ([imagePaths count] == 1) {
        [_photo2 setBackgroundImage:[UIImage imageNamed:@"afterSaleAdd"] forState:UIControlStateNormal];
        _photo2.hidden = NO;
        _photo3.hidden = YES;
    }
    if ([imagePaths count] == 2) {
        [_photo3 setBackgroundImage:[UIImage imageNamed:@"afterSaleAdd"] forState:UIControlStateNormal];
        _photo2.hidden = NO;
        _photo3.hidden = NO;
    }
    if ([imagePaths count] == 3) {
        _photo2.hidden = NO;
        _photo3.hidden = NO;
    }
    if ([imagePaths count] > 0) {
        for (int i = 0; i < [imagePaths count]; i++) {
            NSDictionary *info = imagePaths[i];
            if (i == 0) {
                [_photo1 setBackgroundImage:info[@"img"] forState:UIControlStateNormal];
            }
            if (i == 1) {
                [_photo2 setBackgroundImage:info[@"img"] forState:UIControlStateNormal];
            }
            if (i == 2) {
                [_photo3 setBackgroundImage:info[@"img"] forState:UIControlStateNormal];
            }
        }
    }
}

-(void)takePhoto
{
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        [self displayHUDTitle:nil message:@"模拟机不能测试相机"];
        return;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:nil];
}

-(void)LocalPhoto
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController: (UIImagePickerController *)picker didFinishPickingMediaWithInfo: (NSDictionary *)info
{
    UIImage* image = info[UIImagePickerControllerOriginalImage];
    image = [UIImage imageWithData:UIImageJPEGRepresentation(image, 1.0)];
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self uploadImage:image];
}

- (void)showInfo {
    if (_order) {
        [self displayHUD:@"加载中..."];
        [[MLAPIClient shared] orderCommentInfo:_order.ID WithBlock:^(NSDictionary *attributes, MLResponse *response) {
            [self displayResponseMessage:response];
            if (response.success) {
                NSLog(@"%@",response.data);
                NSArray *goodslist = response.data[@"goodslist"];
                goodsArray = [MLGoods createGoodsWithArray:goodslist];
                [_tableView reloadData];
            }
        }];
    }
}

- (IBAction)sendComment:(id)sender {
    if ([goodsArray count] == 0) {
        return;
    }
    if (_commentTextView.text.length == 0) {
        [self displayHUDTitle:nil message:@"请输入内容!"];
        return;
    }
    [self displayHUD:@"加载中..."];
    NSMutableArray *infoArray = [NSMutableArray array];
    for (int i = 0; i < [goodsArray count]; i++) {
        MLGoods *goods = goodsArray[i];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        dict[@"goodsid"] = goods.ID;
        dict[@"unique"] = goods.unique;
        dict[@"content"] = _commentTextView.text;
        NSMutableArray *imgs = [NSMutableArray array];
        for (int j = 0; j < [imagePaths count]; j++) {
            NSDictionary *dict = imagePaths[i];
            [imgs addObject:dict[@"url"]];
        }
        if ([imgs count] > 0) {
            dict[@"images"] = imgs;
        }
        dict[@"stars"] = star;
        [infoArray addObject:dict];
    }
    NSLog(@"%@", infoArray);
    NSData *jsonData = [self toJSONData:infoArray];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData
                                              encoding:NSUTF8StringEncoding];
    [[MLAPIClient shared] sendComment:_order.ID commentInfo:jsonStr WithBlock:^(NSDictionary *attributes, MLResponse *response) {
        if (response.success) {
            [self displayHUDTitle:nil message:@"评价成功"];
            [self performSelector:@selector(back) withObject:nil afterDelay:1.0];
            return;
        }
        [self displayResponseMessage:response];
    }];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSData *)toJSONData:(id)theData{
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:theData
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if ([jsonData length] > 0 && error == nil){
        return jsonData;
    }else{
        return nil;
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    if ([textView.text length] == 0) {
        _placeholderLabel.hidden = NO;
        return;
    }
    _placeholderLabel.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [MLGoodsOrderTableViewCell height];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [goodsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MLGoodsOrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[MLGoodsOrderTableViewCell identifier]];
    if (!cell) {
        cell = [[MLGoodsOrderTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[MLGoodsOrderTableViewCell identifier]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    MLGoods *goods = goodsArray[indexPath.row];
    cell.goods = goods;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}


@end
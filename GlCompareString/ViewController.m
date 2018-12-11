//
//  ViewController.m
//  GlCompareString
//
//  Created by gleeeli on 2018/10/22.
//  Copyright © 2018年 gleeeli. All rights reserved.
//

#import "ViewController.h"
#import "GlTwoTextEditDistance.h"
#import "GlCompareTwoText.h"

@interface ViewController ()
@property (nonatomic, strong) GlTwoTextEditDistance *compareByDistance;//编辑距离法

@property (nonatomic, strong) GlCompareTwoText *compareByExhaustive;//穷举法

@property (weak, nonatomic) IBOutlet UILabel *rightTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *matchTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *methodOneResultLabel;
@property (weak, nonatomic) IBOutlet UILabel *methodTwoResultLabel;

@property (nonatomic, assign) NSTimeInterval startTime;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NSString *text1 = @"cafe 你现在认识不到互联网项目的好处，就是因为你的思维还没有到位";
//    NSString *text2 = @"icoffee 你gleeeli现在认识不gleeeli到互联网项目的好处";
    NSString *text1 = @"你现在认识不到互联网项目的好处，就是因为你的思维还没有到位，比如很多富翁都是干互联网的，比如马云，比如马化腾，当然还有很多世界级的首富，都是干互联网的，你只是看见他们赚钱，却不想他们为什么赚钱";
    NSString *text2 = @"你现在认识不到物联网项目的好处，因为你的思维还没有到位，比如很多富翁都是干互联网的，比如马云，比如马化腾，当然还有很多世界级的首富，都是干互联网的，你只是看见他们赚钱，却不去想他们为什么赚钱";
    
    self.rightTextLabel.text = text1;//正确的文本
    self.matchTextLabel.text = text2;
    self.startTime = [[NSDate date] timeIntervalSince1970];
    
    __weak typeof(self) weakSelf = self;
    //方法一
    self.compareByDistance = [[GlTwoTextEditDistance alloc] init];
    
    NSInteger allcount = text1.length;
//    for (int i = 0; i < 20; i++) {
    
    
        [self.compareByDistance editDistanceOC:text2 rightStr:text1];
        self.compareByDistance.completeAllBlock = ^(NSInteger minDistance, NSArray<GlEditDistanceModel *> * _Nonnull stepArray, NSString * _Nonnull matchStr) {
            CGFloat simililarity = 1 - minDistance /(CGFloat)allcount;
            if (simililarity < 0) {
                simililarity = 0;
            }else if(simililarity > 1) {
                simililarity = 1;
            }
            NSLog(@"最小距离:%zd,相似度:%f",minDistance,simililarity);
            [weakSelf printAllStepWithStepArray:stepArray minDistance:minDistance simililarity:simililarity];
        };
        
//        NSInteger length = text2.length - 1;
//        text2 = [text2 substringWithRange:NSMakeRange(0, length)];
//    }
    
    //方法二
//    self.compareByExhaustive = [[GlCompareTwoText alloc] init];
//    self.compareByExhaustive.establishMatchLenght = 2;
//    self.compareByExhaustive.completeBlock = ^(GlCompareTextModel * _Nonnull bestModel) {
//        [weakSelf printBestModel:bestModel];
//    };
//
//    [self.compareByExhaustive evaluateStr:text2 rightStr:text1];
    
}

- (void)printAllStepWithStepArray:(NSArray *)stepArray minDistance:(NSInteger)minDistance simililarity:(CGFloat)simililarity{
    NSLog(@"*************************Method One*************************");
    NSString *str2= self.rightTextLabel.text;//正确文本
    NSString *str1 = self.matchTextLabel.text;
    
    NSMutableAttributedString *muStr = [[NSMutableAttributedString alloc] initWithString:str1];
    NSMutableAttributedString *rmuStr = [[NSMutableAttributedString alloc] initWithString:str2];
    
    NSString *sameStr = @"";
    for (long i = [stepArray count] - 1; i >=0 ; i --) {
        GlEditDistanceModel *model = stepArray[i];
        NSString *icur = model.iCursor > 0? [NSString stringWithFormat:@"%C",[str1 characterAtIndex:model.iCursor - 1]] : @"首位";
        
        if (model.stepType == GlStepNone) {
            sameStr = [NSString stringWithFormat:@"%@%@",sameStr,icur];
            NSRange range = NSMakeRange(model.iCursor - 1, 1);
            [muStr addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:range];
            
            NSRange rRange = NSMakeRange(model.jCursor - 1, 1);
            [rmuStr addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:rRange];
        }
        
        //下面打印具体的每一步操作
        NSString *op = @"无操作";
        switch (model.stepType) {
            case GlStepDelete:{
                op = @"删除";
            }
                break;
            case GlStepInsert:{
                NSString *jcur = [NSString stringWithFormat:@"%C",[str2 characterAtIndex:model.jCursor - 1]];
                op = [NSString stringWithFormat:@"插入%@",jcur];
            }
                break;
            case GlStepSubstitute:{
                NSString *jcur = [NSString stringWithFormat:@"%C",[str2 characterAtIndex:model.jCursor - 1]];
                op = [NSString stringWithFormat:@"替换%@",jcur];
            }
                break;
                
            default:{//GlStepNone
                
            }
                break;
        }
        GlDebugLog(@"当前字符:%@,%@",icur,op);
    }
    GlDebugLog(@"相同的字段为:%@",sameStr);
    
    self.matchTextLabel.attributedText = muStr;
    self.rightTextLabel.attributedText = rmuStr;
    
    NSTimeInterval completeTime = [[NSDate date] timeIntervalSince1970];
    NSString *result = [NSString stringWithFormat:@"（绿色为匹配正确的字符）\n错误个数或最小距离：%zd\n相似度:%.1f%%\n耗时：%f",minDistance,simililarity * 100,(completeTime - self.startTime)];
    self.methodOneResultLabel.text = result;
    NSLog(@"*************************Method One End*************************");
}

- (void)printBestModel:(GlCompareTextModel *)model{
    NSTimeInterval completeTime = [[NSDate date] timeIntervalSince1970];
    NSInteger minResult = model.replaceCount + model.deleteCount + model.insertCount;
    NSString *result = [NSString stringWithFormat:@"错误个数或最小距离：%zd",minResult];
    result = [NSString stringWithFormat:@"最优结果:%zd \n替换的：%zd\n删除的:%zd\n插入的:%zd\n耗时：%f秒",model.minResult,model.replaceCount,model.deleteCount,model.insertCount,(completeTime - self.startTime)];
    self.methodTwoResultLabel.text = result;
}

@end

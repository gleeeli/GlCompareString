# GlCompareString
比较两个字符串或文本,编辑距离，相似度，不同点


![image](https://github.com/gleeeli/GlCompareString/blob/master/GlcompareEffect.png)


使用方法：


 __weak typeof(self) weakSelf = self;
    //方法一
    self.compareByDistance = [[GlTwoTextEditDistance alloc] init];
    
    NSInteger allcount = text1.length;
    [self.compareByDistance editDistanceOC:text2 rightStr:text1];
    self.compareByDistance.completeAllBlock = ^(NSInteger minDistance, NSArray<GlEditDistanceModel *> * _Nonnull stepArray, NSString * _Nonnull matchStr) {
            CGFloat simililarity = 1 - minDistance /(CGFloat)allcount;
            if (simililarity < 0) {
                simililarity = 0;
            }else if(simililarity > 1) {
                simililarity = 1;
            }
            NSLog(@"最小距离:%zd,相似度:%f",minDistance,simililarity);
      };

/**
 * 界面元素的稳定标识，供 UI 自动化测试定位控件。
 *
 * 为什么需要这个文件：UI 测试若按按钮文字查找控件，改一次文案就会导致测试失败；
 * 串流画面由 Metal 渲染，在测试的元素树里没有可读文字，只能靠标识定位。
 * 把标识集中在这里，App 与测试代码引用同一份定义，不会各自写错字符串。
 *
 * 用 #define 而非 static 常量：测试代码在独立的 target 中编译，宏不产生符号，
 * 两边无需链接同一份实现。
 */

#ifndef CAIDemoAccessibilityIds_h
#define CAIDemoAccessibilityIds_h

#pragma mark - 登录页

#define CAIIdLoginModeSwitch  @"login.modeSwitch"
#define CAIIdLoginUserId      @"login.userId"
#define CAIIdLoginPassword    @"login.password"
#define CAIIdLoginToken       @"login.token"
#define CAIIdLoginAccessInfo  @"login.accessInfo"
#define CAIIdLoginStart       @"login.start"

#pragma mark - 实例列表页

#define CAIIdListBack           @"list.back"
#define CAIIdListSelectAll      @"list.selectAll"
#define CAIIdListTable          @"list.table"
#define CAIIdListSelectionInfo  @"list.selectionInfo"
#define CAIIdListEnter          @"list.enter"
#define CAIIdListEmpty          @"list.empty"

#pragma mark - 实例操作页

/// 列表与网格的 cell 用实例 ID 作为标识，测试失败时能直接看出是哪台实例
#define CAIIdControlBack        @"control.back"
#define CAIIdControlSettings    @"control.settings"
#define CAIIdControlGrid        @"control.grid"
#define CAIIdControlCellMaster  @"control.cell.master"
#define CAIIdControlCellSlave   @"control.cell.slave"
#define CAIIdControlApiMenu     @"control.apiMenu"

#pragma mark - 串流页

#define CAIIdStreamingBack     @"streaming.back"
#define CAIIdStreamingSetting  @"streaming.setting"
/// 云端画面的渲染视图：可见即表示串流通路已建立，也是截图对比的取景区域
#define CAIIdStreamingRender   @"streaming.render"
/// 首帧渲染后才显示，可作为「画面已出图」的判据
#define CAIIdStreamingStats    @"streaming.stats"

#pragma mark - 通用

/// 加载遮罩：出现表示正在等待网络结果，消失表示本步已结束
#define CAIIdLoading  @"common.loading"
/// 轻提示：操作结果（含失败原因）都经它展示，是断言错误信息的入口
#define CAIIdToast    @"common.toast"

#endif /* CAIDemoAccessibilityIds_h */

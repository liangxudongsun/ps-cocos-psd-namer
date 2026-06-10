# Cocos PSD Namer — Photoshop 图层命名插件（CEP）

配套 **cocos-psd-prefab-2x** 的 Photoshop 面板:**选中图层 → 点按钮 → 批量给图层名加前缀**
(`btn_`/`lay_v_`/`sv_`…),让美术按转换器认得的命名规范快速标注图层。

- 支持**多选**图层一次批量改名。
- 切换前缀会**自动去掉旧的类型前缀**再加新的(可在面板里关掉)。
- 一键**去前缀还原**;也能标注 `// 注释` / `! 忽略` / `ref_` / `tmp_`。
- 兼容 **Photoshop CC2015 ~ 2025**(CEP 6+)。

## 按钮对应（与转换器一致）

| 按钮 | 加的前缀 | 转换后 |
|------|----------|--------|
| btn_ 按钮 | `btn_` | cc.Button |
| lbl_ 文本 / rt_ 富文本 | `lbl_` / `rt_` | Label / RichText |
| sp_ 九宫格 | `sp_` | 九宫格 Sprite(记得名字后再补 `#上,右,下,左`) |
| node_ / mask_ / edit_ / prog_ / tog_ | 同名 | 空容器 / Mask / EditBox / ProgressBar / Toggle |
| lay_v_ / lay_h_ / lay_grid_ | 同名 | 带 Layout 的容器(纵/横/网格) |
| sv_ 滚动视图 | `sv_` | cc.ScrollView |
| ref_ / tmp_ / // / ! | 同名 | 转换时**忽略**该层 |
| 去掉前缀 | (清空) | 还原成无前缀 |

## 安装（一次性）

### 1. 放到 CEP 扩展目录
把本文件夹(含 `CSXS/`、`index.html`、`host.jsx`)整个复制到,并改名为 `com.cocos.psdnamer`:

- **Windows**:`C:\Users\<你的用户名>\AppData\Roaming\Adobe\CEP\extensions\com.cocos.psdnamer\`
- **macOS**:`~/Library/Application Support/Adobe/CEP/extensions/com.cocos.psdnamer/`

(没有 `CEP\extensions` 目录就手动新建。)

### 2. 允许未签名扩展(PlayerDebugMode)
本扩展未做 ZXP 签名,需开启调试模式:

- **Windows**:`Win+R` 输入 `regedit`,定位到 `HKEY_CURRENT_USER\Software\Adobe\CSXS.11`
  (没有就新建项;不同 PS 版本可能是 `CSXS.9 / .10 / .11 / .12`,都建一遍最稳),
  新建**字符串值** `PlayerDebugMode`,数据填 `1`。
- **macOS**:终端执行(各版本都设一遍)
  ```bash
  defaults write com.adobe.CSXS.11 PlayerDebugMode 1
  defaults write com.adobe.CSXS.12 PlayerDebugMode 1
  ```

### 3. 重启 Photoshop
菜单 **窗口 / 扩展功能(旧版)→ Cocos PSD Namer**(Window > Extensions (legacy))打开面板。

## 用法

1. 在图层面板里选中一个或多个图层(可 Ctrl/Shift 多选)。
2. 点面板上对应的前缀按钮即可批量改名。
3. 想换前缀,直接点另一个按钮(默认会替换旧前缀);想还原点「去掉前缀」。

## 说明 / 限制

- `host.jsx` 用 ActionManager 读取/重命名**选中图层**(按图层 ID 改名,支持多选,
  不会改变当前选择)。每次改名是一步可撤销的历史记录。
- 这是开发态加载(未签名)。要分发给团队可用 Adobe `ZXPSignCmd` 打包成 `.zxp` 再用
  Anastasiy's Extension Manager / UPIA 安装,就不需要 PlayerDebugMode。
- 若打开面板按钮无反应:确认 PlayerDebugMode 已设、PS 已重启;部分版本菜单在
  「窗口 / 扩展功能」而非「(旧版)」。

## 目录结构

```
com.cocos.psdnamer/
├── CSXS/manifest.xml   扩展清单(host=PHXS, panel)
├── index.html          面板 UI(按钮 + 逻辑,内置极简 CSInterface)
└── host.jsx            ExtendScript:按 ID 给选中图层加/换/去前缀
```

# Voxy 着色器开发者文档 (Version 1)

为了让 Voxy 支持你的光影包，你需要一个新的“程序”文件：`voxy.json`（它需要与你的其他 gbuffer 程序等放在一起，并且是按维度区分的）。这个程序是一个 JSON 文件（我知道这并非最佳方案，抱歉）。

在深入了解细节之前，这是一个最小化的* `voxy.json` 示例：

```json
{
  "version": 1,
  "uniforms": [],
  "samplers": {},
  "opaqueDrawBuffers": [0],
  "translucentDrawBuffers": [0],
  "opaquePatchData": "void voxy_emitFragment(VoxyFragmentParameters parameters) {discard;}",
  "translucentPatchData": "void voxy_emitFragment(VoxyFragmentParameters parameters) {discard;}"
}
```

上面的配置不会渲染任何 LOD，因为它会立即丢弃（discard）不透明和半透明阶段的所有片元。

### 修补系统 (The Patching System)

在展开讲解 JSON 文件之前，先描述一下修补系统以及你的数据如何与 Voxy 交互。

你的修补代码实际上就是字面意义上的“补丁”。它会被按原样复制并粘贴到 Voxy 自身着色器（片元着色器）的末尾。Voxy 会对它认为合适的每个片元调用你的片元着色器。

**你不允许做的事情：**
*   **导数 (Derivatives) 目前是被禁止的。** 这是因为 Voxy 会在调用你的代码之前丢弃辅助线程（helper threads）和其他无效线程，这意味着在 V1 版本中进行导数计算属于未定义行为。
*   **`discard` 在技术上是不允许的**（尽管在 V1 中如果确实需要可以使用，但在未来版本中可能会被移除），因为未来的渲染系统可能根本不支持 discard（例如计算着色器光栅化等）。

#### 如何编写你的修补着色器

`voxy_emitFragment` 函数会被调用，并传入一个结构体 `VoxyFragmentParameters`，其定义如下：

```glsl
struct VoxyFragmentParameters {
    vec4 sampledColour;
    vec2 tile;
    vec2 uv;
    uint face;
    uint modelId;
    vec2 lightMap;
    vec4 tinting;
    uint customId; // 与 Iris 的 modelId 相同
};
```

你的修补数据必须描述输出缓冲区（像你在着色器中通常做的那样）并写入它们。使用的缓冲区必须在 `opaqueDrawBuffers` 和 `translucentDrawBuffers` 中列出，并按你描述的顺序对它们进行索引。

**重要提示：**
你不允许在你的修补代码中放置 `uniforms`、`ssbos`、`image samplers` 等声明。这些声明将由 Voxy **自动注入** 到你的修补数据之前。这样做的原因是为了在 Voxy 内部代码中统一布局，以避免绑定位置冲突。

### 定义修补数据的方式

关于如何声明修补数据，你有两种选择：
1.  在 JSON 文件中使用 `opaquePatchData` 和 `translucentPatchData`。
2.  使用以下程序文件：`voxy_opaque.glsl`、`voxy_translucent.glsl` 和 `voxy_taa.glsl`（稍后会提到）。

如果这些 `.glsl` 文件可用，Voxy 将优先使用它们，而不是要求在 JSON 文件中描述。

---

### JSON 配置详解

#### Uniforms
`uniforms` 是一个字符串数组，包含你希望在修补中使用的 uniform 名称，例如 `gbufferModelView`、`frameCounter` 等。这包括自定义 uniforms。这些会自动添加/注入到你的修补代码中，所以**绝不要在你的修补数据中定义 UNIFORMS**。

#### Draw Buffers (绘制缓冲区)
`opaqueDrawBuffers` 和 `translucentDrawBuffers` 是整数数组，描述了你想在每个阶段写入的缓冲区。

**注意所有当前的 VOXY 版本（截至撰写时为 0.2.5）：**
半透明缓冲区（TRANSLUCENT BUFFER）是在 VOXY 不透明（OPAQUE）之后立即写入的，在任何其他 Iris 阶段被调用之前。这意味着目前的翻转（flip）顺序可能不正确。

渲染顺序是：
1. 原版不透明/镂空地形 (Vanilla opaque/cutout terrain)
2. Voxy 不透明 (Voxy opaque)
3. Voxy 半透明 (Voxy translucent)
4. 不透明地形之后的其余原版渲染阶段

为了弥补这一点，添加了 4 个额外的 colorTex，意味着你现在可以使用 `0-19`，而不仅仅是 `0-15`。

#### Samplers (采样器)
`samplers` 是一个`字符串到字符串`的映射（Map），第一个是采样器名称，下一个是采样器类型。
*   例如：`{"colortex4":"sampler2D", "shadowtex3":"sampler2DShadow"}`
*   它也可以是一个数组：`["colortex4", "shadowtex3"]`。此时，除了包含 "shadow" 的名称会变为 "sampler2DShadow" 外，所有项都默认为 "sampler2D"。

#### SSBOs
这些描述了 SSBOs 及其使用方式。这是一个`整数到字符串`的映射，其中 `-1` 是特殊的。
*   索引 `-1` 可以看作是头部（header），它插入在任何 SSBO 定义之前。这允许你声明后续会用到的结构体布局等。
*   其他索引是你在 Iris 中通常使用的 SSBO 索引，后跟缓冲区布局。

示例：
```json
{
  "-1": "struct DataThing{vec4 colour; uint data;};",
  "0": "{DataThing dataArray[];}"
}
```
这也意味着 `dataArray` 现在已在你的修补代码中声明并可供使用。

#### Blending (混合)
描述了 `translucentDrawBuffers` 中的缓冲区如何混合。这是一个`整数到字符串`（或`整数到字符串数组`）的映射。
*   `-1` 描述所有缓冲区的默认混合状态。
*   **注意：** 你使用的 Key（键）指定的是在 `translucentDrawBuffers` **数组中的索引**（即第几个缓冲区），以对其进行修改。
    *   例如：如果你有 `translucentDrawBuffers [1,2,3]`。
    *   设置 `blending 0:"off"` 将指定缓冲区 `1` 不进行混合。
*   描述混合的方式与 Iris 相同，但作为字符串。
    *   例如 `"off"`
    *   或者 `"ONE ONE_MINUS_SRC_ALPHA ONE ONE_MINUS_SRC_ALPHA"`
    *   或者作为一个组件数组 `["ONE", "ONE_MINUS_SRC_ALPHA", "ONE", "ONE_MINUS_SRC_ALPHA"]`

#### TAA Offset (TAA 偏移)
`taaOffset` 可能是最奇怪的部分。它是 GLSL 函数的主体，需返回一个 `vec2`，用于指定像素偏移。
*   截至 V1 版本，此函数**只能**访问 `uniforms` 中描述的 uniforms。
*   例如：`{return taa_offset;}` （如果你有一个 vec2 uniform 名为 `taa_offset`）。
*   这一函数旨在变得非常轻量且廉价，并且在给定帧的所有调用中必须是**Uniform 常量**（即整个帧必须是相同的值）。
*   或者，也可以在程序文件 `voxy_taa.glsl` 中指定它。

#### Exclude LODs From Vanilla Depth (从原版深度中排除 LOD)
`excludeLodsFromVanillaDepth` 是一个布尔值，默认为 `false`。
*   当为 `false` 时：LOD 的深度值会被变换并位块传输（blitted）到不透明渲染通道的原版深度缓冲区上。
*   当为 `true` 时：不会发生上述操作。
*   默认开启此功能（指默认包含在深度中）是因为它修复了一些实体、粒子、方块实体即使不应该在 LOD 前面却渲染在前面的问题。
*(译注：原文 "This is enabled by default" 指的是这个行为逻辑默认存在，即该选项默认为 false，LOD **会被** 写入深度)*

#### Render Scale (渲染缩放)
`renderScale` 是一个 1 或 2 元素的浮点数组，指定渲染缩放因子。
*   这是一个纯缩放因子，意味着视口和深度缓冲区本身会按该缩放因子收缩。

#### Use Viewport Dims (使用视口尺寸)
`useViewportDims` 是一个布尔值，默认为 `false`。通常与 `renderScale` 结合使用。
*   它指定输入视口形状（从原版获取的帧缓冲区）作为 Voxy 使用的视口大小。
*   也就是说，如果你的 `renderScale` 为 `[0.5]` 且 `useViewportDims` 为 `true`，输入视口将比默认小 0.5 倍。如果你的地形是用 TAAU 渲染的并且只占据视口的一角，则使用此选项。
*   但是，如果你只希望 LOD 地形在较小的视口渲染而正常地形不是，则 `useViewportDims` 应为 `false`。

### Iris 自动添加的 Uniforms
以下是添加到 Iris 的 Uniforms：
*   `vxRenderDistance` (int) - 以区块（chunks）为单位
*   `vxViewProj`
*   `vxViewProjInv`
*   `vxViewProjPrev`
*   `vxModelView`
*   `vxModelViewInv`
*   `vxModelViewPrev`
*   `vxProj`
*   `vxProjInv`
*   `vxProjPrev`

### 重要说明

**预处理 (Preprocessing):**
所有程序（包括 `voxy.json`）都像在 Iris 中一样进行了预处理（如果不使用非常痛苦的 mixins，这是不可避免的）。这意味着你可以在 `voxy.json` 文件中正常使用 defines 和 ifdefs 等，以及 include 设置文件等。

**宽松解析 (Lenient Parsing):**
`voxy.json` 使用 Gson 以 **LENIENT**（宽松）模式解析。这意味着它会尽力解析文件，包括忽略文件中不属于标准格式的条目。利用这一点，导入设置可以像这样变通过去：

```json
"unusedThing": "
#include \"/lib/settings.glsl\"
"
```

**获取面法线 (Face Normal):**
从 Voxy 获取面法线的一种方法是：
```glsl
vec3 normal = vec3(uint((face>>1)==2), uint((face>>1)==0), uint((face>>1)==1)) * (float(int(face)&1)*2-1);
```

**平面距离:**
近平面 (nearplane) 是 `16`，远平面 (farplane) 是 `16*3000`。

**补充**
如果安装了 voxy 且启用了其渲染功能，则会声明 VOXY 宏。从版本 1 开始，它是一个空定义（意味着它只是一个声明，不包含版本或任何其他信息）。
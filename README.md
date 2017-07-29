# unity-wireframe-shader
Unity wireframe material using Geometry Shaders built for the [UCLA Game Lab](http://games.ucla.edu/resource/unity-wireframe-shader/) and [Unity Asset Store](https://www.assetstore.unity3d.com/en/#!/content/21897) in 2013.

Based on work from [this paper](http://cgg-journal.com/2008-2/06/index.html).

## Use
Renders a line along every edge between every vertex. Requires Geometry Shaders, so this only works on DX11.

Only renders wireframe. Two passes can be rendered to render wireframe on top of another solid material or shader can be easily modified to render both in the same pass.

## Wireframe Options
### Thickness
How thick the wireframe is

### Cutout
Whether or not to discard pixels outside the wireframe, creating a harder edge, but can draw to depth

## TODO
- [ ] Move all shader variants into one shader using keywords
- [ ] Build a custom material inspector
- [ ] Get pictures

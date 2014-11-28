part of citadel_client;

class Camera extends DisplayObject {
  DisplayObject viewable;
  DisplayObject followedObject;
  Rectangle<int> viewingRect;

  Camera(this.viewable, this.viewingRect) {
    regenerateMask();
  }

  void follow(GameSprite gs) {
    followedObject = gs;
  }

  void updateCameraLocation() {
    if (followedObject == null) { return; }
    // TODO: specify region elsewhere
    // For now, player can see 10 tiles in every direction.
    int distance = toPixels(10);
    var x = followedObject.x.toInt() - distance;
    var y = followedObject.y.toInt() - distance;
    var width  = (distance * 2) + followedObject.width;
    var height = (distance * 2) + followedObject.height;

    viewingRect = new Rectangle(x, y, width, height);

    // We need to orient the camera so that our viewable region is in the upper left corner.
    setTransform(viewingRect.left * -1, viewingRect.top * -1);

    regenerateMask();
  }

  // Rendering

  void regenerateMask() {
    mask = new Mask.rectangle(viewingRect.left, viewingRect.top, viewingRect.width, viewingRect.height);
  }

  void render(RenderState renderState) {
    updateCameraLocation();

    var rs = new RenderState(renderState.renderContext, transformationMatrix);
    var rc = rs.renderContext;

    rc.beginRenderMask(rs, mask);
    viewable.render(rs);
    rc.endRenderMask(rs, mask);
  }
}

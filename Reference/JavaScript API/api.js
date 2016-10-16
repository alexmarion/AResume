YUI.add("yuidoc-meta", function(Y) {
   Y.YUIDoc = { meta: {
    "classes": [
        "ARObject",
        "ARchitectObject",
        "ActionArea",
        "ActionRange",
        "AnimatedImageDrawable",
        "Animation",
        "AnimationGroup",
        "BaseTracker",
        "BoundingRectangle",
        "CONST",
        "Circle",
        "ClientTracker",
        "CloudTracker",
        "Drawable",
        "Drawable2D",
        "GeoLocation",
        "GeoObject",
        "HtmlDrawable",
        "ImageDrawable",
        "ImageResource",
        "Label",
        "Location",
        "Model",
        "ModelAnimation",
        "Positionable",
        "PropertyAnimation",
        "RelativeLocation",
        "Sound",
        "Style",
        "Trackable2DObject",
        "Tracker",
        "VideoDrawable",
        "context",
        "hardware",
        "logger",
        "radar"
    ],
    "modules": [
        "AR"
    ],
    "allModules": [
        {
            "displayName": "AR",
            "name": "AR",
            "description": "In this section, some general concepts are described, which apply to multiple\nclasses within the ARchitect library.<br/>\n\n<h2 class=\"paragraph\">Scaled Distance Units (SDUs)</h2>In AR\napplications, the term \"size of an object\" cannot be defined just in pixels\nor similar size measurements. Unlike in 2-dimensional applications, such as\nmaps, the size of an object inherently depends on the distance from the\nviewer to the object.<br/>\n\nImagine a virtual 2-dimensional logo which should be placed right on top of a\ncertain store location. In a map-based application, the size can easily be\ndefined by specifying the width and height of the logo in pixels. In AR\napplications, the logo should appear as big as the building itself, which is\ndependent on the distance in a natural way. Additionally for geobased usecases\nobjects should be readable even if far away. We use a distance based scaling\n(see below) to accomplish this.<br/>\n\nThe term \"pixels\" or physical units cannot be used in AR applications,\nas they are defined in a static way and do not allow the application to scale\nthe objects in the desired way. Thus, the Wikitude ARchitect introduces Scaled\nDistance Units (SDU). SDUs are defined not only in relation to the object's size\nitself, but also in relation to the distance from the viewer to the object\nitself.<br/>\n\nFor drawables attached to GeoObjects, 1 SDU is defined as the screen-size of\nan object which is exactly 1 meter high and located 10 meters away from the viewer. If a\ndrawable's width is defined as 5 SDU, it will exactly overlap an object which\nis 5 meters wide and is located in 10 meters distance.<br/> For drawables\nattached to Trackable2DObjects, SDUs are determined by the underlying\ntrackable's size. The drawables anchor point will be set to the center of the\nTrackable2DObject, and 1 SDU is defined to be the height of the image, as\ndescribed in the figure below:<br/> <img\nsrc=\"../assets/img/Trackable2DDrawables.jpg\"/> <br/><br/> A circle with\nradius set to 0.25 will be rendered accordingly:<br/> <img\nsrc=\"../assets/img/circleInTrackable.jpg\"/>\n\n<h2 class=\"paragraph\">Distance Based Scaling (DBS)</h2><br/> Another\nimportant concept of an AR application is \"Distance Based Scaling\". Think\nabout the logo again, which represents the store location of a certain brand.\nIf we are in 10 meters viewing distance, the logo will perfectly overlap the\nbuilding, assuming that we have set the drawable's width and height to the right\nSDUs. Now, we are moving away from the store location. Without the concept of\nDistance Based Scaling (DBS), the logo will quickly vanish from the screen, as it will be too small to\nsee - especially when the SDUs are not set to a high value. A similar\nsituation appears when we are moving towards the location - the logo will\nsoon appear very big and obstruct the entire screen.<br/>\n\nTo avoid situations like this, where drawables are only clearly visible in a\ncertain viewing distance, and are otherwise soon too big or too small to see\nrespectively, we introduce DBS.\nDBS ensures that drawables do not exceed certain limits of their original\nappearance.<br/>\n\nYou can define three values, minScalingDistance maxScalingDistance and scalingFactor.<br/> minScalingDistance\ndefines the viewing distance at which the drawables will not be\nscaled anymore. Let's assume a minScalingDistance setting of 10 meters.\nRegardless if the viewing distance is 10 meters or even\ncloser to the original location, the drawable will still have the same size\non the screen. This avoids drawables obstructing the entire screen.<br/>\nmaxScalingDistance defines the viewing distance beyond\nwhich the drawables will not be scaled anymore. Let's assume a maxScalingDistance setting of 200 meters.\nThe drawable will still appear in the same size on the screen, regardless if the distance to the\nobject is 200 meters, or even more. This avoids drawables getting too\nsmall to be seen on the screen.<br/>\nThe scalingFactor controls the size the object takes on at maxScalingDistance, in percentage of the size\nit took on at minScalingDistance. If set to 0.2, on maxScalingDistance, the object will take on 20% of its\nscreen-size size at minScalingDistance. In between minScalingDistance and maxScalingDistance, the scaling\nwill be linear.<br/>\nminScalingDistance, maxScalingDistance and scalingFactor can be set in AR.context.scene."
        }
    ]
} };
});
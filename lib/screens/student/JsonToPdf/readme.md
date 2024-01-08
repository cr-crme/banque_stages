JSONContainer
The JSONContainer class is a subclass of JSONWidget that represents a container widget in a PDF document. It takes a JSON object as input and returns a Container widget with the specified properties.

Properties
widget: A JSON object that contains the properties of the container widget.
Methods
getWidget(): Returns a Container widget with the specified properties.
getPadding(): Returns the padding of the container as an EdgeInsets object.
getMargin(): Returns the margin of the container as an EdgeInsets object.
getWidth(): Returns the width of the container as a double.
getHeight(): Returns the height of the container as a double.
getDecoration(): Returns the decoration of the container as a JSONDecoration object.
getChild(): Returns the child widget of the container as a Widget object.
JSONDecoration
The JSONDecoration class is a helper class that represents the decoration of a container widget in a PDF document. It takes a JSON object as input and returns a BoxDecoration object with the specified properties.

Properties
decoration: A JSON object that contains the properties of the decoration.
Methods
getBoxDecoration(): Returns a BoxDecoration object with the specified properties.
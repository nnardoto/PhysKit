#import "../lib.typ": primitives, mechanics, vectors
#import "../mechanics/solver.typ": resolve

#let a = primitives.polar((0, 0), 2, 30deg)
#assert(calc.abs(a.at(0) - calc.sqrt(3)) < 0.0001)
#assert(calc.abs(a.at(1) - 1) < 0.0001)
#assert(calc.abs(primitives.angle-of((calc.cos(30deg), calc.sin(30deg))) - 30deg) < 0.0001deg)

#let floor = mechanics.floor("floor")
#let box = mechanics.box("box")
#mechanics.diagram(
  objects: (floor, box),
  constraints: (mechanics.on-surface(box, floor, distance: 2),),
)

// An inclined plane is a right triangle and an attached box inherits its angle.
#let ramp = mechanics.inclined-plane("ramp", length: 5, angle: 30deg)
#assert(calc.abs(ramp.base-end.at(0) - ramp.end.at(0)) < 0.0001)
#assert(calc.abs(ramp.base-end.at(1) - ramp.start.at(1)) < 0.0001)
#let inclined-box = mechanics.box("inclined-box")
#let resolved = resolve(
  (ramp, inclined-box),
  (mechanics.on-surface(inclined-box, ramp, distance: 2.5),),
)
#let resolved-box = resolved.filter(object => object.id == "inclined-box").first()
#assert(calc.abs(resolved-box.angle - 30deg) < 0.0001deg)

// A suspended mass is vertically aligned with the pulley port.
#let ceiling = mechanics.ceiling("ceiling", y: 5, from: 0, to: 4)
#let pulley = mechanics.pulley("pulley", radius: 0.5)
#let hanging = mechanics.box("hanging", width: 0.8, height: 0.8)
#let suspended = resolve(
  (ceiling, pulley, hanging),
  (
    mechanics.fixed-to(pulley, ceiling, position: 50%, distance: 0.8),
    mechanics.suspended-from(hanging, pulley, side: "right", length: 1.5),
  ),
)
#let resolved-pulley = suspended.filter(object => object.id == "pulley").first()
#let resolved-hanging = suspended.filter(object => object.id == "hanging").first()
#let hanging-top = primitives.rectangle-anchor(
  resolved-hanging.at,
  resolved-hanging.width,
  resolved-hanging.height,
  resolved-hanging.angle,
  "top",
)
#assert(calc.abs(hanging-top.at(0) - (resolved-pulley.at.at(0) + resolved-pulley.radius)) < 0.0001)

// A computed rope contact is tangent to the pulley radius.
#let external = (0, 0)
#let center = (3, 3)
#let tangent-point = primitives.select-tangent(
  primitives.circle-tangent-points(external, center, 0.5),
  "upper",
)
#assert(calc.abs(primitives.dot(
  primitives.sub(tangent-point, center),
  primitives.sub(external, tangent-point),
)) < 0.0001)

// A coupling makes the incoming rope parallel to the inclined plane while
// preserving exact tangency.
#let parallel-ceiling = mechanics.ceiling(
  "parallel-ceiling",
  y: 8,
  from: 3.5,
  to: 7,
)
#let parallel-pulley = mechanics.pulley("parallel-pulley", radius: 0.55)
#let parallel-block = mechanics.box("parallel-block", width: 1.2, height: 0.8)
#let parallel-resolved = resolve(
  (ramp, parallel-ceiling, parallel-block, parallel-pulley),
  (
    mechanics.on-surface(parallel-block, ramp, distance: 2.8),
    mechanics.align-rope-parallel(
      from: mechanics.connect(parallel-block, "right"),
      pulley: parallel-pulley,
      parallel-to: ramp,
      support: parallel-ceiling,
      support-position: 72%,
      support-distance: 0.8,
    ),
  ),
)
#let aligned-block = parallel-resolved.filter(
  object => object.id == "parallel-block"
).first()
#let aligned-pulley = parallel-resolved.filter(
  object => object.id == "parallel-pulley"
).first()
#let aligned-ceiling = parallel-resolved.filter(
  object => object.id == "parallel-ceiling"
).first()
#let aligned-source = primitives.rectangle-anchor(
  aligned-block.at,
  aligned-block.width,
  aligned-block.height,
  aligned-block.angle,
  "right",
)
#let aligned-entry = aligned-pulley.at("rope-entry").position
#let incoming-rope = primitives.sub(aligned-entry, aligned-source)
#let ramp-direction = primitives.sub(ramp.end, ramp.start)
#assert(calc.abs(primitives.cross(incoming-rope, ramp-direction)) < 0.0001)
#assert(calc.abs(primitives.dot(
  primitives.sub(aligned-entry, aligned-pulley.at),
  incoming-rope,
)) < 0.0001)
#assert(calc.abs(aligned-ceiling.start.at(1) - 8) > 0.1)

// Public label controls are retained in the high-level descriptions.
#let labeled-box = mechanics.box(
  "labeled-box",
  label: [$m$],
  label-offset: (0.2, 0.1),
  label-anchor: "west",
)
#let labeled-weight = mechanics.weight(
  "labeled-weight",
  labeled-box,
  label-position: 65%,
  label-offset: (0.3, 0),
)
#assert(labeled-box.label-offset == (0.2, 0.1))
#assert(labeled-box.label-anchor == "west")
#assert(labeled-weight.label-position == 65%)
#assert(labeled-weight.label-offset == (0.3, 0))

// Cartesian, polar and resultant vector constructions.
#let vector-a = vectors.vector("vector-a", (3, 2))
#let vector-b = vectors.polar-vector("vector-b", 2, 90deg, from: vector-a.end)
#let vector-r = vectors.resultant("vector-r", (vector-a, vector-b))
#assert(calc.abs(vector-b.components.at(0)) < 0.0001)
#assert(calc.abs(vector-b.components.at(1) - 2) < 0.0001)
#assert(vector-r.components == (3, 4))
#vectors.diagram(
  vectors: (vector-a, vector-b, vector-r),
  x-range: (-1, 5),
  y-range: (-1, 5),
  tick-labels: false,
)

// A free-body diagram positions an unresolved body without supports.
#let free-body-box = mechanics.box("free-body-box", label: [$m$])
#mechanics.free-body(
  free-body-box,
  forces: (
    mechanics.weight("free-body-weight", free-body-box),
    mechanics.force("free-body-normal", free-body-box, (0, 1), label: [$N$]),
  ),
)

#import "../../lib.typ": mechanics

#let body = mechanics.box("body", at: (0, 0))
#let invalid = mechanics.rope("rope", (mechanics.connect(body, "right"),))

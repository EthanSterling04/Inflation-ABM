breed [households household]
breed [firms firm]

undirected-link-breed [buyer-to-firm-links buyer-to-firm-link]
directed-link-breed [firm-to-buyer-links firm-to-buyer-link]

households-own [
  income
  consumption
  inflation-expectations
]

firms-own [
  revenue
  investment
]

globals [
  interest-rate
  inflation-target
  output-gap
  inflation
  Y
  exogenous-investment
  aggregate-consumption
  aggregate-investment
  potential-output
]

to setup
  clear-all
  set inflation-target 0.02
  set inflation 0.02
  set exogenous-investment 5000

  ;; set up equilibrium economy
  set Y (exogenous-investment - interest-sensitivity * stabilising-interest-rate) / (1 - MPC)
  set potential-output Y
  set interest-rate (exogenous-investment - (1 - MPC) * Y) / interest-sensitivity

  create-households n-households [
    set income (Y / n-households) ; divide up output into income and investment
    set consumption 0
    set inflation-expectations inflation-target
    move-to one-of patches
    set shape "person"
  ]
  create-firms n-firms [
    ;; assume a PC market where P = MC
    set revenue ((Y - MPC * Y) / n-firms) ; divide up output into income and investment
    set investment 0
    move-to one-of patches
    set shape "truck"
  ]
  reset-ticks
end

to go
  ask households [
    decide-consumption
    find-and-buy
    update-inflation-expectations
  ]
  ask firms [
    decide-investment
    find-and-pay
  ]
  update-macro-variables
  set-interest-rate
  tick
  clear-temporary-links
end

to decide-consumption
  ;; Households decide consumption based on their income

  ;; The MPC is not strongly influenced by interest rates; consumption tends to be stable relative to income.
  ;; In theory one might think that higher interest rates would induce more saving (the substitution effect)
  ;; but higher interest rates also mean than people do not have to save as much for the future.

  ;; C = c*Y
  let mpcHousehold random-normal MPC 0.1
  set consumption (mpcHousehold * income)
  set income (income - consumption)
end

to find-and-buy
  ;; Buy from a random firm using consumption as spending
  let target-firm one-of firms
  if target-firm != nobody [
    if consumption >= 0 [
      create-buyer-to-firm-link-with target-firm [
        set color lime + 1
      ]
      ask target-firm [
        set revenue revenue + [consumption] of myself
      ]
    ]
  ]
end

to update-inflation-expectations
  ;; Update inflation expectations adaptively
  let inflationAdaptabilityHousehold random-normal inflation-adaptability 0.1
  set inflation-expectations (inflationAdaptabilityHousehold * inflation + (1 - inflationAdaptabilityHousehold) * inflation-expectations)
end

to decide-investment
  ;; Firms decide on investment based on interest rate
  let interestSensitivityFirm random-normal interest-sensitivity 0.1
  set investment max list ((exogenous-investment - interestSensitivityFirm * interest-rate) / n-firms) 0  ; Ensure investment is non-negative
  set revenue revenue - investment
end

to find-and-pay
  ;; Pay a random household using investment as wages
  let target-household one-of households
  if target-household != nobody [
    if investment >= 0 [
      create-firm-to-buyer-link-to target-household [
        set color violet + 2
      ]
      ask target-household [
        set income (income + [investment] of myself)
      ]
    ]
  ]
end

to update-macro-variables
  ;; Calculate the output based on the IS curve

  ;; Calculate AD based on aggregation
  set aggregate-consumption sum [consumption] of households
  set aggregate-investment sum [investment] of firms

  ;; AD = cY + (I‾ - b * i)
  let AD aggregate-consumption + aggregate-investment

  ;; IS Curve: Y = (I‾ - b * i) / (1 - c)
  ;set Y (exogenous-investment - interest-sensitivity * interest-rate) / (1 - MPC)
  set Y aggregate-investment / (1 - MPC)
  set potential-output (exogenous-investment - interest-sensitivity * stabilising-interest-rate) / (1 - MPC)

  ;; Calculate output-gap
  ;; (y1 − ye)
  set output-gap (Y - potential-output)

  ;; Calculate inflation using the inflation-augmented Phillips curve
  ;; π1 = π0 + α(y1 − ye)
  set inflation (mean [inflation-expectations] of households) - inflation-sensitivity * output-gap

  ;; Assume Neutrality of Money, which suggests that in the long run, changes in the money supply
  ;; only affect nominal variables like prices and wages, without impacting real variables such as output,
  ;; consumption, and investment, thereby implying that inflation affects the price level but not the real economy.

end

to set-interest-rate
  ;; Adjust the interest rate based on the policy rule

  ;; Policy Rule: (y1 − ye) = −αβ(π1 − πT)
  ;; Substitute for π1 using the Phillips curve: π0 − πT = −(α + 1/αβ)(y1 − ye)
  ;; substitute for (y1 − ye) using the IS equation: π0 − πT = −(α + 1/αβ)(y1 − ye)
  ;; i = r − [((π0−πT)⋅(1−c)) / (b⋅(α + 1/αβ))]
  set interest-rate stabilising-interest-rate - ((inflation - inflation-target) * (1 - MPC)) / (interest-sensitivity * (inflation-sensitivity + 1 / (inflation-sensitivity * loss-balance)))
  set interest-rate max list interest-rate 0  ; Ensure interest rate is non-negative
end

to clear-temporary-links
  ask buyer-to-firm-links [ die ]
  ask firm-to-buyer-links [ die ]
end

;; Carlin, W., Soskice, D. (2009). Teaching Intermediate Macroeconomics using the 3-Equation Model.
;; In: Fontana, G., Setterfield, M. (eds) Macroeconomic Theory and Macroeconomic Pedagogy. Palgrave Macmillan,
;; London. https://doi.org/10.1007/978-0-230-29166-9_2

;; Witte, Mark. “3-Equation Macro Model.” Class lecture, Economics 311 Intermediate Macroeconomics,
;; Northwestern University, Evanston, IL.

;; Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for
;; Connected Learning and Computer-Based Modeling, Northwestern University,
;; Evanston, IL.
@#$#@#$#@
GRAPHICS-WINDOW
277
14
714
452
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
1
1
1
ticks
30.0

BUTTON
50
95
116
128
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
142
95
205
128
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
42
15
214
48
n-households
n-households
1
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
42
53
214
86
n-firms
n-firms
1
100
40.0
1
1
NIL
HORIZONTAL

PLOT
746
14
946
164
Macro
NIL
NIL
0.0
10.0
9085.0
0.0
true
true
"" ""
PENS
"Interest Rate" 1.0 0 -2674135 true "" "plot interest-rate * 100 + Y"
"Inflation" 1.0 0 -10899396 true "" "plot inflation * 100 + Y"
"Output" 1.0 0 -13791810 true "" "plot Y"

SLIDER
38
261
224
294
interest-sensitivity
interest-sensitivity
0.01
1
0.6
.01
1
NIL
HORIZONTAL

SLIDER
37
158
224
191
MPC
MPC
0
1
0.4
.01
1
NIL
HORIZONTAL

SLIDER
38
388
226
421
inflation-sensitivity
inflation-sensitivity
0
1
0.35
.01
1
NIL
HORIZONTAL

SLIDER
38
326
224
359
loss-balance
loss-balance
0
2
1.0
.01
1
NIL
HORIZONTAL

SLIDER
37
197
223
230
inflation-adaptability
inflation-adaptability
0
1
0.5
.01
1
NIL
HORIZONTAL

MONITOR
728
174
792
219
Inflation
inflation * 100
3
1
11

MONITOR
798
175
890
220
Interest Rate
interest-rate * 100
3
1
11

MONITOR
898
175
956
220
Output
Y
1
1
11

TEXTBOX
37
139
137
157
Households
11
0.0
1

TEXTBOX
38
244
138
262
Firms
11
0.0
1

TEXTBOX
38
371
138
389
Model
11
0.0
1

TEXTBOX
40
308
176
326
Monetary
11
0.0
1

PLOT
745
233
945
383
Agents
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Consumption" 1.0 0 -11085214 true "" "plot mean [consumption] of households"
"Investment" 1.0 0 -10141563 true "" "plot mean [investment] of firms"
"Income" 1.0 0 -1184463 true "" "plot mean [income] of households"
"Revenue" 1.0 0 -2674135 true "" "plot mean [revenue] of firms"

MONITOR
726
390
780
435
Income
mean [income] of households
2
1
11

MONITOR
782
390
836
435
Revenue
mean [revenue] of firms
2
1
11

MONITOR
838
390
888
435
C
mean [consumption] of households
2
1
11

MONITOR
891
390
961
435
Investment
mean [investment] of firms
4
1
11

MONITOR
866
94
938
139
NIL
output-gap
4
1
11

SLIDER
38
431
227
464
stabilising-interest-rate
stabilising-interest-rate
0
0.15
0.05
0.01
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

A model of inflation in a circular economy with two types of agents, households and firms based on the 3-equation model. Households purchase goods/services from firms based on their consumption preferences and firms determine investment levels based on interest and pay households for labor with that investment. Inflation is updated based on expected inflation of households and the output gap is measured and appropriate interest rates are set to stabilize the economy.

## THE 3-EQUATION MODEL

The 3-equation model is a simplified version of the New Keynesian Dynamic Stochastic General Equilibrium (DSGE) model, which is widely used in macroeconomic analysis and monetary policy decision-making. It consists of three equations: an IS (Investment-Saving) curve, a Phillips curve, and a monetary policy rule.

* The IS curve relates the output gap (the difference between actual and potential output) to the real interest rate and other factors affecting aggregate demand.

* The Phillips curve describes the relationship between inflation and the output gap, capturing the short-run tradeoff between inflation and economic activity.

* The monetary policy rule specifies how the central bank adjusts the nominal interest rate in response to deviations of inflation from its target and the output gap.

The model provides a simplified framework for analyzing the effects of monetary policy shocks, demand shocks, and supply shocks on key macroeconomic variables like output, inflation, and interest rates.

## HOW IT WORKS

*Initialize*

* Set initial macroeconomic variables to be in equilibrium
* Calculate and set the stabilizing interest rate
* Create n-households and n-firms

*At each clock tick:*

Each household does:

* Decide consumption based on `MPC`
* Find and buy from random firm using my consumption
* Update inflation expectations based on `inflation-adaptability`

Each firm does:

* Decide investment based on `investment-sensitivity` and interest rate
* Find and pay random household using my investment

The model does:

* Update macro variables based on the 3-equation model
* Set interest rate based on the policy rule

## HOW TO USE IT

Simulation Setup:

* `n-households`: number of household agents
* `n-firms`: number of firm agents
* Setup: Click "Setup" to initialize the variables.

Running the Simulation:

* Run: Click "Go" to start the simulation. The model will run continuously until paused or stopped.

Parameters:

* `MPC`: marginal propensity to consume
* `inflation-adaptability`: how adaptable households’ inflation expectations are (1 is adaptive, 0 is grounded)
* `interest-sensitivity`: how sensitive investment is to interest changes
* `loss-balance`: how inflation and unemployment is balanced by the policy rule (1 is perfectly balanced)
* `inflation-sensitivity`: how sensitive inflation is to the output gap
* `stabilising-interest-rate`: the interest rate that keeps the economy in equilibrium

Monitoring the Economy:

* Macro Graph: A graph will track the inflation, interest, and output over time
* Agent Graph: A graph will track the consumption, investment, income, and revenue over time


## THINGS TO NOTICE

Notice how agent variables relate to eachother and how their movement impacts the overall macro economy. Another thing to observe is how interest rates, inflation, and output-gap all effect eachother.

## THINGS TO TRY

Try changing sliders to see how they effect the equilibrium output. A good combination is interest-sensitivity and loss-balance to get bigger or smaller fluctuations around the stabilizing interest rate. 

## EXTENDING THE MODEL

Extend consumption and investment to consumers paying for goods/services with prices and firms paying households a competitive wage. This will help further factor inflation into the model. Building off of this, you can implement competitive game theory models for firm investment decisions along with a marginal cost to create their good/service. This will help make the model more realistic.

Another cool idea is to add buttons to create temporary shocks to the economy and see how it self-adjusts.

## NETLOGO FEATURES

Uses NetLogo's `random-normal` feature to randomly   household and firm properties around the mean.

## CREDITS AND REFERENCES

Carlin, W., Soskice, D. (2009). Teaching Intermediate Macroeconomics using the 3-Equation Model. In: Fontana, G., Setterfield, M. (eds) Macroeconomic Theory and Macroeconomic Pedagogy. Palgrave Macmillan, London. https://doi.org/10.1007/978-0-230-29166-9_2

Witte, Mark. “3-Equation Macro Model.” Class lecture, Economics 311 Intermediate Macroeconomics, Northwestern University, Evanston, IL. 

Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="inflation-adaptability vs demand shocks" repetitions="5" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup
set n 49</setup>
    <go>go
ifelse n = 0 [
set exogenous-investment exogenous-investment + 1000
set stabilising-interest-rate (exogenous-investment - (1 - MPC) * potential-output) / interest-sensitivity
set n 100
] [
set n n - 1
]</go>
    <timeLimit steps="100"/>
    <metric>interest-rate</metric>
    <metric>inflation</metric>
    <metric>Y</metric>
    <metric>mean [consumption] of households</metric>
    <metric>mean [investment] of firms</metric>
    <metric>mean [income] of households</metric>
    <metric>mean [revenue] of firms</metric>
    <enumeratedValueSet variable="stabilising-interest-rate">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inflation-adaptability">
      <value value="0"/>
      <value value="0.25"/>
      <value value="0.5"/>
      <value value="0.75"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inflation-sensitivity">
      <value value="0.35"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MPC">
      <value value="0.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interest-sensitivity">
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-firms">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-households">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-balance">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@

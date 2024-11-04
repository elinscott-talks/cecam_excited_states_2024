#import "@preview/touying:0.4.2": *
#import "@preview/pinit:0.1.4": *
#import "@preview/xarrow:0.3.0": xarrow
#import "@preview/cetz:0.3.0"
#import "psi-slides.typ"


#let cetz-canvas = touying-reducer.with(reduce: cetz.canvas, cover: cetz.draw.hide.with(bounds: true))

// color-scheme can be navy-red, blue-green, or pink-yellow
#let s = psi-slides.register(aspect-ratio: "16-9", color-scheme: "pink-yellow")

#let s = (s.methods.info)(
  self: s,
  title: [Koopmans functionals],
  subtitle: [Baking localised charged excitation energies into DFT],
  author: [Edward Linscott],
  date: datetime(year: 2024, month: 11, day: 7),
  location: [CECAM Workshop on Excited States],
  references: [references.bib],
)
#let blcite(reference) = {
  text(fill: white, cite(reference))
}

#set footnote.entry(clearance: 0em)
#show bibliography: set text(0.6em)

#let (init, slides) = utils.methods(s)
#show: init

#let (slide, empty-slide, title-slide, new-section-slide, focus-slide, matrix-slide) = utils.slides(s)
#show: slides


Koopmans functionals: a correction to DFT tailored to improve spectral properties

#pause

- Theory
  - what physical conditions motivate these functionals?
  - what approximations do we make? #pause
- Results
  - what sort of accuracy can these functionals achieve? #pause
- Extensions
  - where can we employ machine learning to speed up these calculations?
  - what do we need to do to go beyond single-particle excitations?
  - what have we done to make these functionals accessible? #pause
- Open questions
  - what don't we understand? #pause

= Theory

#matrix-slide(title: "Spectral properties")[
  #image("figures/arpes.png", height: 100%)
][
  #image("figures/puppin.png", height: 100%)
]

== ... with a functional theory?

We all know that DFT underestimates the band gap. But why? #pause

The exact Green's function has poles that correspond to total energy differences

$
  ε_i = cases(E(N) - E_i (N-1) & "if" i in "occ", E_i (N+1) - E(N) & "if" i in "emp")
$ #pause

but DFT does #emph[not]

#focus-slide()[Core idea: impose this equivalence to DFT and thereby improve its description of spectral properties]

#matrix-slide()[
  Formally, every orbital $i$ should have an eigenenergy
  $
    epsilon_i^"Koopmans" = ⟨
      phi_i mid(|)hat(H)mid(|)phi_i
    ⟩ = frac(dif E, dif f_i)
  $
  that is
  - #pause independent of $f_i$
  - #pause equal to $Delta E$ of explicit electron addition/removal
][
  #pause
  #image(width: 100%, "figures/fig_en_curve_gradients_zoom_2.png")
]
#matrix-slide(columns: (1fr, 1fr))[

$
  E^"KI" &[rho, {rho_i}] =
  E^"DFT" [rho]
  \ & +
  sum_i {
    - underbrace((E^"DFT" [rho] - E[rho^(f_i arrow.r 0)]), "remove non-linear dependence")
  \ &
    + underbrace(f_i (E^"DFT" [rho^(f_i arrow.r 1)] - E^"DFT" [rho^(f_i arrow.r 0)]), "restore linear dependence")
  }
$

Bakes the total energy differences $E^"DFT" [rho^(f_i arrow.r 1)] - E^"DFT" [rho^(f_i arrow.r 0)]$ into the functional

][
  #image(width: 100%, "figures/fig_en_curve_gradients_zoom_2.png")
]

== 

// $E[rho^(f_i arrow.r f)]$ is the energy of the $N - f_i + f$-electron problem with orbital $i$'s occupation changed from $f_i$ to $f$ -- cannot directly evaluate
// 
// Instead use a frozen-orbital picture:
// 
// $
//  rho^(f_i arrow.r f)(bold(r)) approx rho(bold(r)) + (f - f_i) |phi^N_i (bold(r))|^2
// $
// 
// very easy to evaluate -- but not at all accurate! Correct this _post hoc_ via a screening parameter i.e.
// 
// $
//   E[rho^(f_i arrow.r f)] approx alpha_i E[rho + (f - f_i) |phi^N_i (bold(r))|^2]
// $
#matrix-slide(columns: (1fr, 1fr, 1fr))[
#cetz.canvas({
  import cetz.draw: *
  content((1.25, 1.5), [$rho$])
  circle((0, 0), radius: 1, fill: s.colors.primary, stroke: none)
  circle((2.5, 0), radius: 1, fill: s.colors.primary, stroke: none)
})
$N$-electron solution
#pause
][
#cetz.canvas({
  import cetz.draw: *

  content((9, 1.5), [$rho^(f_1 arrow.r 0)$])
  arc((10.75, 0), start: 0deg, stop: 360deg, radius: (1.5, 1), fill: s.colors.primary, stroke: none)
  circle((8, 0), radius: 1, fill: none, stroke: (thickness: 2pt, paint: s.colors.primary))
  circle((8, 0), radius: 1, fill: none, stroke: (dash: "dashed", thickness: 2pt, paint: white))
  // content((8, -1.5), [$f_1 = 0$])
})
what appears in the functional
#pause
][
#cetz.canvas({
  import cetz.draw: *

  content((17.25, 1.5), [$rho - |psi^N_1(r)|^2$])
  circle((16, 0), radius: 1, fill: none, stroke: (dash: "dashed", thickness: 2pt, paint: s.colors.primary))
  circle((18.5, 0), radius: 1, fill: s.colors.primary, stroke: none)
})
what we can quickly evaluate
]

==
$
  E^"KI"_bold(alpha) [rho, {rho_i}] = &
  E^"DFT" [rho]
  \ & +
  sum_i {
    - (E^"DFT" [rho] - E^"DFT" [rho^(f_i arrow.r 0)])
    + f_i (E^"DFT" [rho^(f_i arrow.r 1)] - E^"DFT" [rho^(f_i arrow.r 0)])
  }
  \ approx & 
  E^"DFT" [rho]
  \ & +
  sum_i alpha_i {
    - (E^"DFT" [rho] - E^"DFT" [rho - rho_i])
    + f_i (E^"DFT" [rho - rho_i + n_i] - E^"DFT" [rho - rho_i])
  }
$

where $rho_i (bold(r)) = f_i|phi_i (bold(r))|^2 = f_i n_i (bold(r))$

#slide[
#align(center + horizon, 
  image("figures/fig_pwl.png", height: 100%)
)
]

==
$
  E^"KI"_bold(alpha) [rho, {rho_i}] = &
  E^"DFT" [rho]
  \ & +
  sum_i {
    - (E^"DFT" [rho] - E^"DFT" [rho^(f_i arrow.r 0)])
    + f_i (E^"DFT" [rho^(f_i arrow.r 1)] - E^"DFT" [rho^(f_i arrow.r 0)])
  }
  \ approx & 
  E^"DFT" [rho]
  \ & +
  sum_i alpha_i {
    - (E^"DFT" [rho] - E^"DFT" [rho - rho_i])
    + f_i (E^"DFT" [rho - rho_i + n_i] - E^"DFT" [rho - rho_i])
  }
$

where $rho_i (bold(r)) = f_i|phi_i (bold(r))|^2 = f_i n_i (bold(r))$


== Screening

Construct $alpha_i$ from explicit $Delta$SCF calculations@Nguyen2018@DeGennaro2022a

$
  alpha_i = alpha_i^0 (Delta E_i - lambda_(i i)(0)) / (lambda_(i i)(alpha^0) - lambda_(i i)(0)) "where" lambda_(i i)(alpha) = angle.l phi_i|hat(h)^"DFT" + alpha hat(v)_i^"KI"|phi_i angle.r $

Recast via linear response@Colonna2018:

$
  alpha_i = (angle.l n_i|epsilon^(-1) f_"Hxc"|n_i angle.r) / (angle.l n_i|f_"Hxc"|n_i angle.r)
$

which can be efficiently computed via DFPT@Colonna2022 #pause ... but is still the bulk of the computational cost (can use machine-learning)

== Orbital-density dependence
An orbital-density-dependent energy functional: 
$
  E^"KI"_bold(alpha) [rho, {rho_i}] = &
  E^"DFT" [rho]
  \ & +
  sum_i alpha_i {
    - (E^"DFT" [rho] - E^"DFT" [rho - rho_i])
    + f_i (E^"DFT" [rho - rho_i + n_i] - E^"DFT" [rho - rho_i])
  }
$

#pause
... and an orbital-dependent potential:
$ H^"KI"_(i j) = angle.l phi_j|hat(h)^"DFT" + alpha_i hat(v)_i^"KI"|phi_i angle.r $

#pause
  $ v^"KI"_(i in"occ") = - E_"Hxc" [rho - n_i] + E_"Hxc" [rho] - integral v_"Hxc" (bold(r)', [rho]) n_i (bold(r)') d bold(r)' $

== 
#pause

#slide(title: "Consequences of ODD")[
- #pause loss of rotational invariance; minimisation of total energy is more complicated
- #pause two sets of orbitals:
#align(center,
  grid(columns: 2,
  image("figures/fig_nguyen_variational_orbital.png", width: 80%),
  image("figures/fig_nguyen_canonical_orbital.png", width:80%),
  [two variational orbitals],
  [a canonical orbital],
  )
)
- #pause we can use MLWFs@Marzari2012
- #pause we know $hat(H)|phi_i angle.r$ but we don't know $hat(H)$ #pause
- a generalisation of DFT in the direction of spectral functional theory@Ferretti2014
]

== Issues with extended systems

#align(center + horizon, 
  image("figures/fig_nguyen_scaling.png", width: 60%)
)

#pause
One cell: $E(N + delta N) - E(N)$ #pause; all cells: $Delta E = 1 / (delta N) (E(N + delta N) - E(N)) = (d E)/ (d N) = - epsilon_(H O)$@Nguyen2018

== Issues with extended systems

#align(center + horizon, 
  image("figures/fig_nguyen_scaling.png", width: 60%)
)

Two options: #pause _1._ use a more advanced functional#pause, or _2._ stay in the "safe" region

== A brief summary
$
  E^"KI"_bold(alpha) [rho, {rho_i}] =
  E^"DFT" [rho] +
  sum_i alpha_i { &
    - (E^"DFT" [rho] - E^"DFT" [rho - rho_i])
  \ &
    + f_i (E^"DFT" [rho - rho_i + n_i] - E^"DFT" [rho - rho_i])
  }
$

#pause
- an orbital-by-orbital correction to DFT #pause
- localised charge excitations baked into derivatives #pause
- screening parameters #pause
- orbital-density-dependence #pause
- total energy unchanged!
= Results

== Molecular systems

=== Ionisation potentials@Colonna2019
#align(center + horizon,
image("figures/colonna_2019_gw100_ip.jpeg", width: 100%)
)

=== UV photoemission spectra@Nguyen2015
#align(center + horizon,
image("figures/fig_nguyen_prl_spectra.png", width: 100%)
)

== Extended systems
#slide[
=== Prototypical semiconductors and insulators @Nguyen2018

#show table.cell: it => {
  if it.x == 3 or it.x == 4 {
    set text(fill: s.colors.primary, weight: "semibold")
    it
  } else {
    it
  }
}

#grid(align: center + horizon, columns: 2, column-gutter: 1em,
image("figures/fig_nguyen_prx_bandgaps.png", height: 80%),
table(columns: (auto, 1fr, 1fr, 1fr, 1fr, 1fr), inset: 0.5em, stroke: none,
table.header([], [PBE], [G#sub[0]W#sub[0]], [KI], [KIPZ], [QSGW̃]),
table.hline(),
[$E_"gap"$], [2.54], [0.56], [0.27], [0.22], [0.18],
[IP], [1.09], [0.39], [0.19], [0.21], [0.49]
))
  
]

#slide[
=== ZnO @Colonna2022
#v(-1em)
#align(center + horizon,
grid(align: center + horizon, columns: 3, column-gutter: 1em,
image("figures/ZnO_lda_cropped.png", height: 80%),
image("figures/ZnO_hse_cropped_noaxis.png", height: 80%),
image("figures/ZnO_ki_cropped_noaxis.png", height: 80%),
))
]

#slide[
=== ZnO @Colonna2022
#show table.cell: it => {
  if it.x == 5 {
    set text(fill: s.colors.primary, weight: "semibold")
    it
  } else {
    it
  }
}
#table(columns: (auto, 1fr, 1fr, 1fr, 1fr, 1fr, 1.5fr), inset: 0.5em, stroke: none,
table.header([], [LDA ], [HSE ], [GW#sub[0] ], [scGW̃ ], [KI ], [exp ]),
table.hline(),
[$E_"gap"$], [0.79], [2.79], [3.0], [3.2], [3.68], [3.60],
[$angle.l epsilon_d angle.r$], [-5.1], [-6.1], [-6.4], [-6.7], [-6.9], [-7.5 to -8.81 ],
[$Delta$], [4.15], [], [], [], [4.99], [5.3]
)
  
]

=== Spin-orbit coupling@Marrazzo2024

#v(-3em)
#align(center + horizon,
image("figures/marrazzo_CsPbBr3_bands.svg", width: 45%)
)
#table(columns: (auto, 1fr, 1fr, 1fr, 1fr, 1fr, 1.5fr), inset: 0.5em, stroke: none,
table.header([], [LDA ], [HSE ], [G#sub[0]W#sub[0] ], [QSGW̃ ], [KI ], [exp ]),
table.hline(),
[without SOC ], [1.40], [2.09], [2.56], [3.15], [3.12], [],
[with SOC], [0.18], [0.78], [0.94], [1.53], [1.78], [1.85],
)

== Model systems
=== Hooke's atom@Schubert2023

#align(center + horizon, 
  image("figures/schubert_vxc.jpeg", height: 85%)
)

= Caveats

== Limitations

- only valid for systems with $E_"gap"$ > 0 #pause
- empty state localisation in the bulk limit #pause
- can break crystal point group symmetry

== Resonance with other efforts

- Wannier transition state method of Anisimov and Kozhevnikov@Anisimov2005
- Optimally-tuned range-separated hybrid functionals of Kronik, Pasquarello, and others@Kronik2012@Wing2021
- Ensemble DFT of Kraisler and Kronik@Kraisler2013
- Koopmans-Wannier method of Wang and co-workers@Ma2016
- Dielectric-dependent hybrid functionals of Galli and co-workers@Skone2016a
- Scaling corrections of Yang and co-workers@Li2018

= Electronic screening via machine learning

== Electronic screening via machine learning

A key ingredient of Koopmans functional calculations are the screening parameters:

$
  alpha_i = (angle.l n_i|epsilon^(-1) f_"Hxc"|n_i angle.r) / (angle.l n_i|f_"Hxc"|n_i angle.r)
$

#pause

- a local measure of the degree by which electronic interactions are screened #pause
- one screening parameter per (non-equivalent) orbital #pause
- must be computed #emph[ab intio] via $Delta$SCF@Nguyen2018@DeGennaro2022a or DFPT@Colonna2018@Colonna2022 #pause
- corresponds to the vast majority of the computational cost of Koopmans functional calculation

== The machine-learning framework

#slide[
  #align(
    center,
    grid(
      columns: 5,
      align: horizon,
      gutter: 1em,
      image("figures/orbital.emp.00191_cropped.png", height: 30%),
      xarrow("power spectrum decomposition"),
      $vec(delim: "[", x_0, x_1, x_2, dots.v)$,
      xarrow("ridge regression"),
      $alpha_i$,
    ),
  )

  $
    c^i_(n l m, k) & = integral dif bold(r) g_(n l) (r) Y_(l m)(theta,phi) n^i (
      bold(r) - bold(R)^i
    )
  $


  $
    p^i_(n_1 n_2 l,k_1 k_2) = pi sqrt(8 / (2l+1)) sum_m c_(n_1 l m,k_1)^(i *) c_(n_2 l m,k_2)^i
  $

  #blcite(<Schubert2024>)
]

== Two test systems

#slide[
  #align(
    center,
    grid(
      columns: 2,
      align: horizon + center,
      gutter: 1em,
      image("figures/water.png", height: 70%),
      image("figures/CsSnI3_disordered.png", height: 70%),

      "water", "CsSnI" + sub("3"),
    ),
  )
  #blcite(<Schubert2024>)
]

== Results: screening parameters

#slide[
  #grid(
    columns: (1fr, 1fr),
    align: horizon + center,
    gutter: 1em,
    image(
      "figures/water_cls_calc_vs_pred_and_hist_bottom_panel_alphas.svg",
      height: 70%,
    ),
    image(
      "figures/CsSnI3_calc_vs_pred_and_hist_bottom_panel_alphas.svg",
      height: 70%,
    ),

    "water", "CsSnI" + sub("3"),
  )
  #blcite(<Schubert2024>)
]

== Results: balancing accuracy and speedup

#slide[
  #grid(
    columns: (1fr, 1fr),
    align: center + horizon,
    gutter: 1em,
    image(
      "figures/convergence_analysis_Eg_only.svg",
      height: 60%,
    ),
    image("figures/speedup.svg", height: 60%),

    "accurate to within " + $cal("O")$ + "(10 meV) " + emph("cf.") + " typical band gap accuracy of " + $cal("O")$ + "(100 meV)",
    "speedup of " + $cal("O")$ + "(10) to " + $cal("O")$ + "(100)",
  )
  #blcite(<Schubert2024>)
]

#focus-slide[
Takeaway: predicting electronic response can be done efficiently with frozen-orbital approximations and machine learning
]

= Going beyond single-particle excitations (preliminary)

The idea: solve the BSE, skipping GW and instead using Koopmans eigenvalues@Lautenschlager1987@Sottile2003

#align(center + horizon,
grid(columns: 2, image("figures/si_ki_vs_gw.png", height: 70%),
image("figures/si_literature_spectra.png", height: 70%))
)

N.B. using DFT response

= Making Koopmans functionals accessible

== The general workflow

#image("figures/supercell_workflow.png", width: 100%)

#image("figures/primitive_workflow.png", width: 65.5%)

== 

Because we have...
- bespoke code
- complicated workflows

then...
- there is lots of scope for human error
- reproducibility becomes difficult
- expert knowledge required

==
#align(center, image(width: 50%, "figures/koopmans_grey_on_transparent.png"))

An ongoing effort to make Koopmans functional calculations straightforward for non-experts@Linscott2023

- easy installation
- automated workflows
- minimal input required of the user

For more details, go to `koopmans-functionals.org`

#matrix-slide(title: "Making Koopmans functionals accessible")[
  #image("figures/black_box_filled_square.png")
][
 
  + scriptable with `python`

  + #pause automated Wannerisation #pause

  + integration with `AiiDA`@Huber2020
]

= Summary

== Summary
#matrix-slide(
  columns: (1fr, 2fr),
  gutter: 1em,
  image("figures/fig_nguyen_prx_bandgaps.png", width: 100%),
  text[
    Koopmans functionals...
    - bake localised charged excitation energies into DFT #pause
    - give band structures with comparable accuracy to state-of-the-art GW #pause
    - machine learning can be used to calculate the screening parameters @Schubert2024 #pause
    - can be used in place of GW in BSE calculation of excitons #pause
    - is available in the easy-to-use package `koopmans`
  ],
)

== Open questions

- why does correcting _local_ charged excitations correct the description of delocalized excitations?
- is there a good metric for selecting variational orbitals (_i.e._ the subspace with respect to which we enforce piecewise linearity)?
- are off-diagonal corrections appropriate? What form should they take?
- how to extend to metallic systems?
- can we provide a formal basis for the Koopmans correction?
  - GKS
  - spectral functional theory@Ferretti2014
  - ensemble DFT
  - RDMFT

== Acknowledgements
#align(
  center,
  grid(
    columns: 4,
    align: horizon + center,
    gutter: 1em,
    image("media/mugshots/nicola_marzari.jpeg", height: 45%),
    image("media/mugshots/nicola_colonna.png", height: 45%),
    // image("media/mugshots/junfeng_qiao.jpeg", height: 45%),
    image("media/mugshots/yannick_schubert.jpg", height: 45%),
    image("media/mugshots/miki_bonacci.jpg", height: 45%),

    text("Nicola Marzari"),
    text("Nicola Colonna"),
    // text("Junfeng Qiao"),
    text("Yannick Schubert"),
    text("Miki Bonacci"),
  ),
)

#align(
  center,
  grid(
    columns: 2,
    align: horizon + center,
    gutter: 2em,
    image("media/logos/snf_color_on_transparent.png", height: 20%),
    image("media/logos/marvel_color_on_transparent.png", height: 20%),
  ),
)

= Spare slides

#matrix-slide(title: "Calculating screening parameters via SCF", columns: (1fr, 1fr))[
#align(center + horizon,
  {only("1")[#image("figures/alpha_calc/fig_alpha_calc_step_0.png", height: 100%)]
  only("2")[#image("figures/alpha_calc/fig_alpha_calc_step_1.png", height: 100%)]
  only("3")[#image("figures/alpha_calc/fig_alpha_calc_step_2.png", height: 100%)]
  only("4-5")[#image("figures/alpha_calc/fig_alpha_calc_step_3.png", height: 100%)]
  only("6-7")[#image("figures/alpha_calc/fig_alpha_calc_step_4.png", height: 100%)]
  }
)
][
#only("7")[$ alpha_i = alpha_i^0 (Delta E_i - lambda_(i i)(0)) / (lambda_(i i)(alpha^0) - lambda_(i i)(0)) $
$ lambda_(i i)(alpha) = angle.l phi_i|hat(h)^"DFT" + alpha hat(v)_i^"KI"|phi_i angle.r $]
]

== The key ingredients of automated Wannierisation

#grid(
  columns: (2fr, 2fr, 3fr),
  align: center + horizon,
  gutter: 1em,
  image("figures/proj_disentanglement_fig1a.png", height: 60%),
  image("figures/new_projs.png", height: 60%),
  image("figures/target_manifolds_fig1b.png", height: 60%),

  text("projectability-based disentanglement") + cite(<Qiao2023>),
  text("use PAOs found in pseudopotentials"),
  text("parallel transport to separate manifolds") + cite(<Qiao2023a>),
)

== Connections with approximate self-energies@Ferretti2014@Colonna2019

Orbital-density functional theory:

$ (h + alpha_i v^(K I)_i)|psi_i angle.r = lambda_i|psi_i angle.r $ $v_i^(K I)(bold(r))$ is real, local, and state-dependent #pause

cf. Green's function theory:

$ (h + Sigma_i)|psi_i angle.r = z_i|psi_i angle.r $ $Sigma_i (bold(r), bold(r)')$ is complex, non-local, and state-dependent

#slide[
Hartree-Fock self-energy in localized representation

$Sigma_x (bold(r), bold(r)') = - sum_(k sigma)^("occ") psi_(k sigma)(bold(r)) & f_H (bold(r), bold(r'))psi^*_(k sigma)(bold(r)') \
& arrow.r.double.long angle.l phi_(i sigma)|Sigma_x|phi_(j sigma') angle.r approx - angle.l phi_(i sigma)|v_H [n_(i sigma)]|phi_(i sigma)angle.r delta_(i j)delta_(sigma sigma')$

Unscreened KIPZ#sym.at Hartree ($v_"xc" arrow.r 0$; $f_"Hxc" arrow.r f_H$; $epsilon^(-1) arrow.r 1$)

$angle.l phi_(i sigma)|v^"KIPZ"_(j sigma',"xc")|phi_(j sigma') angle.r
approx {(1/2 - f_(i sigma)) angle.l n_(i sigma)|f_H|n_(i sigma) angle.r - E_H [n_(i sigma)]}
approx - angle.l phi_(i sigma)|v_H [n_(i sigma)]|phi_(i sigma)angle.r delta_(i j)delta_(sigma sigma')$

]

#slide[
Screened exchange plus Coulomb hole (COHSEX)

$ Sigma^"SEX"_"xc" (bold(s), bold(s)') = - sum_(k sigma)^"occ" psi_(k sigma)(bold(r)) psi_(k sigma)^*(bold(r)) W(bold(r), bold(r)') $

$ Sigma^"COH"_"xc" (bold(s), bold(s)') = 1/2 delta(bold(s), bold(s)'){W(bold(r), bold(r)') - f_H (bold(r), bold(r)')} $

$ arrow.r.double.long angle.l phi_(i sigma)|Sigma^"COHSEX"_"xc"|phi_(j sigma')angle.r approx {(1/2 - f_(i sigma)) angle.l n_(i sigma)|W|n_(i sigma)angle.r - E_H [n_(i sigma)]}delta_(i j) delta_(sigma sigma')$

KIPZ#sym.at Hartree with RPA screening ($v_"xc" arrow.r 0$; $f_"Hxc" arrow.r f_H$; $epsilon^(-1) arrow.r "RPA"$)

$ angle.l phi_(i sigma)|v^"KIPZ"_(j sigma',"xc")|phi_(j sigma')angle.r approx{(1/2 - f_(i sigma)) angle.l n_(i sigma)|W|n_(i sigma)angle.r - E_H [n_(i sigma)]}delta_(i j) delta_(sigma sigma')$
]

#slide[
  Static GWΓ#sub[xc] --- local (DFT-based) vertex corrections@Hybertsen1987@DelSole1994

  $ Sigma^(G W Gamma_"xc")_"xc"(1, 2) = i G(1, 2) W_(t-e) (1, 2) $
  
  $ W_(t-e) = (1 - f_"Hxc" chi_0)^(-1) f_H $

  $ arrow.r.double.long angle.l phi_(i sigma)|Sigma^(G W Gamma_"xc")_"xc"|phi_(j sigma')angle.r approx{(1/2 - f_(i sigma)) angle.l n_(i sigma)|W_(t-e)|n_(i sigma)angle.r - E_H [n_(i sigma)]}delta_(i j) delta_(sigma sigma')$

  KIPZ#sym.at DFT ($v_"xc" arrow.r$ DFT; $f_"Hxc" arrow.r$ DFT; $epsilon^(-1) arrow.r$ DFT)

  $ angle.l phi_(i sigma)|v^"KIPZ"_(j sigma',"xc")|phi_(j sigma')angle.r approx{angle.l phi_(i sigma)|v^"DFT"_(sigma,"xc")|phi_(i sigma)angle.r + (1/2 - f_(i sigma)) angle.l n_(i sigma)|epsilon^(-1)_(t-e) f_"Hxc"|n_(i sigma)angle.r - E_H [n_(i sigma)]}delta_(i j) delta_(sigma sigma')$
]

== References
#bibliography("references.bib")

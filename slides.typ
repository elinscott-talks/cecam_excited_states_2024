#import "@preview/touying:0.4.2": *
#import "@preview/pinit:0.1.4": *
#import "@preview/xarrow:0.3.0": xarrow
#import "psi-slides.typ"
#import "@preview/cetz:0.3.0"

#let cetz-canvas = touying-reducer.with(reduce: cetz.canvas, cover: cetz.draw.hide.with(bounds: true))

// color-scheme can be navy-red, blue-green, or pink-yellow
#let s = psi-slides.register(aspect-ratio: "16-9", color-scheme: "pink-yellow")

#let s = (s.methods.info)(
  self: s,
  title: [Koopmans functionals],
  subtitle: [Baking knowledge of localized charged excitations into DFT],
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


== Outline
Koopmans functionals: a correction to DFT tailored to improve spectral properties

- Theory
  - what physical conditions motivate these functionals?
  - what key approximations underpins them?
- Results
  - what sort of accuracy can these functionals achieve?
- Extensions
  - where can we employ machine learning to speed up these calculations?
  - what do we need to do to go beyond charged excitations?
  - how can we make these calculations accessible?
- Open questions
  - what don't we understand?

== Koopmans functional basics

We all know that DFT underestimates the band gap. But why?

The exact Green's function has poles that correspond to total energy differences

$
  ε_i = cases(E(N) - E_i (N-1) & "if" i in "occ", E_i (N+1) - E(N) & "if" i in "emp")
$

but DFT does #emph[not]

#focus-slide()[Core idea: impose this condition to DFT to improve its description of spectral properties]

#matrix-slide()[
  Formally, every orbital $i$ should have an eigenenergy
  $
    epsilon_i^"Koopmans" = ⟨
      phi_i mid(|)hat(H)mid(|)phi_i
    ⟩ = frac(dif E, dif f_i)
  $
  that is
  - independent of $f_i$
  - equal to $Delta E$ of explicit electron addition/removal
][
  #image(width: 100%, "figures/fig_en_curve_gradients_zoom.svg")
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
  #image(width: 100%, "figures/fig_en_curve_gradients_zoom.svg")
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
#align(center + horizon, 
grid(align: center + horizon, columns: 3, column-gutter: 2cm, row-gutter: 1cm,
cetz.canvas({
  import cetz.draw: *
  content((1.25, 1.5), [$rho$])
  circle((0, 0), radius: 1, fill: s.colors.primary, stroke: none)
  circle((2.5, 0), radius: 1, fill: s.colors.primary, stroke: none)

}),
cetz.canvas({
  import cetz.draw: *

  content((9, 1.5), [$rho^(f_1 arrow.r 0)$])
  arc((10.75, 0), start: 0deg, stop: 360deg, radius: (1.5, 1), fill: s.colors.primary, stroke: none)
  circle((8, 0), radius: 1, fill: none, stroke: (thickness: 2pt, paint: s.colors.primary))
  circle((8, 0), radius: 1, fill: none, stroke: (dash: "dashed", thickness: 2pt, paint: white))
  // content((8, -1.5), [$f_1 = 0$])
}),
cetz.canvas({
  import cetz.draw: *

  content((17.25, 1.5), [$rho - |psi^N_1(r)|^2$])
  circle((16, 0), radius: 1, fill: none, stroke: (dash: "dashed", thickness: 2pt, paint: s.colors.primary))
  circle((18.5, 0), radius: 1, fill: s.colors.primary, stroke: none)
}),
[$N$-electron solution],
[what we'd like to evaluate],
[what we can evaluate]

))


==
$
  E^"KI"_bold(alpha) [rho, {rho_i}] = &
  E^"DFT" [rho]
  \ & +
  sum_i {
    - (E^"DFT" [rho] - E[rho^(f_i arrow.r 0)])
    + f_i (E^"DFT" [rho^(f_i arrow.r 1)] - E^"DFT" [rho^(f_i arrow.r 0)])
  }
  \ approx & 
  E^"DFT" [rho]
  \ & +
  sum_i alpha_i {
    - (E^"DFT" [rho] - E[rho - rho_i])
    + f_i (E^"DFT" [rho - rho_i + n_i] - E^"DFT" [rho - rho_i])
  }
$

and
$H^"KI"_(i j) = angle.l phi_j|hat(h)^"DFT" + alpha_i hat(v)_i^"KI"|phi_i angle.r$
where for _e.g._ occupied orbitals $ hat(v)^"KI"|phi_i angle.r = - E_"Hxc" [rho - n_i] + E_"Hxc" [rho] - integral v_"Hxc" (bold(r)', [rho]) n_i d bold(r)' $

== Screening

Construct $alpha$ from explicit $Delta$SCF calculations:

$ alpha_i = () / () $

or, more efficiently, the same quantity via linear response:

$
  alpha_i = (angle.l n_i mid(|) epsilon^(-1) f_"Hxc" mid(|) n_i angle.r) / (angle.l n_i mid(|) f_"Hxc" mid(|) n_i angle.r)
$

which can be efficiently computed via DFPT.

Will discuss later now we can use machine-learning to speed this up

== Orbital-density dependence
- minimisation gives rise to localised orbitals, so we want to first Wannierise to initialise (or even define) these orbitals #pause

== A powerful tool for computational spectroscopy

#grid(
  columns: (4fr, 1fr, 2fr, 1fr),
  rows: (auto, auto, auto, auto),
  align: (horizon + right, horizon + left, horizon + right, horizon + left),
  gutter: 1em,
  grid.cell(image("figures/colonna_2019_gw100_ip.jpeg", height: 30%)),
  text("ionisation potentials", size: 0.8em) + cite(<Colonna2019>),
  grid.cell(image("figures/fig_nguyen_prx_bandgaps.png", height: 30%)),
  text("band gaps", size: 0.8em) + cite(<Nguyen2018>),
  grid.cell(image("figures/fig_nguyen_prl_spectra.png", height: 25%)),
  text("photoemission spectra", size: 0.8em) + cite(<Nguyen2015>),
  grid.cell(image("figures/marrazzo_CsPbBr3_bands.svg", height: 30%)),
  text("spin-orbit coupling", size: 0.8em) + cite(<Marrazzo2024>),
)


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

  + #pause automated Wannerisation #pause
  + calculating the screening parameters via machine learning #pause
  + integration with `AiiDA`
]

= Automated Wannierisation

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

== Example 1: TiO#sub[2]
#grid(
  columns: (1fr, 1fr),
  align: center + horizon,
  gutter: 1em,
  image("figures/TiO2_wannierize_bandstructure.png", height: 80%),
  text(size: 0.6em, raw(read("scripts/tio2.json"), block: true, lang: "json")),
)

== Example 2: LiF
#slide[
  #image("figures/default.png", height: 80%)
][
  #uncover("2-", image("figures/Li_only.png", height: 80%))
]


= Electronic screening via machine learning

== Electronic screening via machine learning

A key ingredient of Koopmans functional calculations are the screening parameters:

$
  alpha_i = (angle.l n_i mid(|) epsilon^(-1) f_"Hxc" mid(|) n_i angle.r) / (angle.l n_i mid(|) f_"Hxc" mid(|) n_i angle.r)
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

= Integration with `AiiDA`

== Integration with `AiiDA`

Work has begun to interface `koopmans` with `AiiDA`, which would allow for...
#pause

- remote execution #pause
- parallel execution #pause
- making use of `AiiDA`'s workflows #pause
- deployment as a GUI (see Miki Bonacci's talk immediately after this one)

#pause

The strategy we are employing...
- requires a moderate amount of refactoring #pause
- will not change `koopmans`' user interface #pause

Watch this space!

= Summary

== Summary
#grid(
  columns: (1fr, 2fr),
  gutter: 1em,
  image("figures/black_box_filled_square.png", width: 100%),
  text[
    Koopmans functionals are
    - a powerful tool for computational spectroscopy, and
    - are increasingly user-friendly:
      - Wannierisation is more black-box @Qiao2023@Qiao2023a
      - machine learning can be used to calculate the screening parameters @Schubert2024
      - parallel and remote execution with `AiiDA` is on the horizon
      - GUI development is also underway (up next!)
  ],
)

== Acknowledgements
#align(
  center,
  grid(
    columns: 5,
    align: horizon + center,
    gutter: 1em,
    image("media/mugshots/nicola_marzari.jpg", height: 45%),
    image("media/mugshots/nicola_colonna.png", height: 45%),
    image("media/mugshots/junfeng_qiao.jpeg", height: 45%),
    image("media/mugshots/yannick_schubert.jpg", height: 45%),
    image("media/mugshots/miki_bonacci.jpg", height: 45%),

    text("Nicola Marzari"),
    text("Nicola Colonna"),
    text("Junfeng Qiao"),
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

== References
#bibliography("references.bib")

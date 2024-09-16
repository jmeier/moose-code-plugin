# This test contains blocks of 3D elements and blocks with 2D elements.

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
  use_displaced_mesh = false
[]

[Problem]
  solve = true
[]

[Mesh]
  [BaseMesh]
    type = GeneratedMeshGenerator
    subdomain_name = 'BaseMesh'
    elem_type = 'HEX8'
    dim = 3
    nx = 1
    ny = 1
    nz = 1
    xmin = -1
    xmax = +1
    ymin = -1
    ymax = +1
    zmin = -1
    zmax = +1
  []
[]

[Physics]
  [SolidMechanics]
    [QuasiStatic]
      [all]
        strain = SMALL
        incremental = true
        add_variables = true
        generate_output = 'stress_xx stress_yy stress_zz'
      []
    []
  []
[]

[AuxVariables]
  [E_phys]
    family = MONOMIAL
    order = CONSTANT
  []
[]

[AuxKernels]
  [E_phys]
    type = FunctionAux
    function = 'YoungsModulusFunction'
    variable = 'E_phys'
    execute_on = 'INITIAL TIMESTEP_BEGIN'
  []
[]

# fix the lower model boundary in x, y and z direction
[BCs]
  [back_fix_x]
    type = DirichletBC
    variable = disp_x
    boundary = 'back'
    value = 0.0
  []
  [back_fix_y]
    type = DirichletBC
    variable = disp_y
    boundary = 'back'
    value = 0.0
  []
  [back_fix_z]
    type = DirichletBC
    variable = disp_z
    boundary = 'back'
    value = 0.0
  []
[]

[Functions]
  [YoungsModulusFunction]
    type = StepFunction
    start_time = 0.5
    start_value = 1e6
    end_time = 0.7
    end_value = 2e6
  []
[]

# Material: Volume Elements
[Materials]

  [youngs_modulus]
    type = GenericFunctionMaterial
    prop_names = 'youngs_modulus'
    prop_values = YoungsModulusFunction
  []

  [elasticity_tensor]
    type = ComputeVariableIsotropicElasticityTensor
    youngs_modulus = youngs_modulus
    poissons_ratio = 0.15
    args = 'E_phys'
    output_properties = 'youngs_modulus'
  []

  [stress]
    type = ComputeFiniteStrainElasticStress
  []
[]

[Preconditioning]
  [.\SMP]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient

  end_time = 1.0
  dtmin = 0.001
  [TimeSteppers]
    [BlockEventTimeStepper]
      type = TimeSequenceStepper
      time_sequence = '0.1 0.5 0.55 0.6 0.65 0.7 1.0'
    []
  []

  solve_type = 'Newton'
  petsc_options = '-snes_converged_reason'
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = ' lu       mumps'

  l_tol = 1E-10
  l_max_its = 20

  nl_abs_tol = 1E-10
  nl_rel_tol = 1e-8
  nl_max_its = 20
[]

[Outputs]
  exodus = true
[]

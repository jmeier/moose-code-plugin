//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "MooseError.h"

// MOOSE includes
#include "InputParameters.h"
#include "StepFunction.h"
#include "FEProblemBase.h"

registerMooseObject(MOOSEAPPNAME, StepFunction);

InputParameters
StepFunction::validParams()
{
  InputParameters params = Function::validParams();

  params.addRequiredParam<Real>("start_time", "Start time for the transition from start to end value.");
  params.addRequiredParam<double>("start_value", "Start value.");

  params.addRequiredParam<Real>("end_time", "End time for the transition from start to end value.");
  params.addRequiredParam<double>("end_value", "end value.");

  MooseEnum step_function_type_choice("Linear=0 Smooth=1 Perlin=2", "Perlin");
  params.addRequiredParam<MooseEnum>("step_function_type",
                             step_function_type_choice,
                             "Type of the step function used for the transition.");

  params.addClassDescription("Step function acting on time (constant over space).");

  return params;
}

StepFunction::StepFunction(const InputParameters & parameters)
  : Function(parameters),
    _step_function_type(getParam<MooseEnum>("step_function_type").getEnum<StepFunctionType>()),
    _start_time(getParam<Real>("start_time")),
    _start_value(getParam<double>("start_value")),
    _end_time(getParam<Real>("end_time")),
    _end_value(getParam<double>("end_value"))
{
}

Real
StepFunction::value(Real t, const Point & /*p*/) const
{
  if (t == _last_value_t)
  {
    return _last_value;
  };

  Real y = getValueInternal(t, false);

  _last_value_t = t;
  _last_value = y;

  return y;
}

RealGradient
StepFunction::gradient(Real /*t*/, const Point & /*p*/) const
{
  // this function only depends on time
  return 0;
}

Real
StepFunction::timeDerivative(Real t, const Point & /*p*/) const
{
  if (t == _last_timeDerivative_t)
    return _last_timeDerivative;

  Real y = getValueInternal(t, true);

  _last_timeDerivative_t = t;
  _last_timeDerivative = y;

  return y;
}

RealVectorValue
StepFunction::vectorValue(Real /*t*/, const Point & /*p*/) const
{
  mooseError("The vectorValue method is not defined in StepFunction");
}

void
StepFunction::initialSetup()
{
}

double
StepFunction::getValueInternal(const Real t, const bool timeDerivative) const
{
  if (timeDerivative == true)
    return evaluateTimeDerivative(_step_function_type, _start_time, _start_value, _end_time, _end_value, t);
  else
    return evaluateValue(
        _step_function_type, _start_time, _start_value, _end_time, _end_value, t);
}

double
StepFunction::evaluateValue(const StepFunctionType type,
                            const Real start_time,
                            const double start_value,
                            const Real end_time,
                            const double end_value,
                            const Real t)
{
  if (t < start_time)
  {

    // we are before start_time - just return start_value
    return start_value;
  }
  else if (t >= end_time)
  {

    // we are at or after end_time - just return end_value
    return end_value;
  }
  else
  {

    // we are in between start_time and end_time
    // let's calculate the dimensionless factor 'f' for time [0..1]
    const double f = (t - start_time) / (end_time - start_time);

    if (type == StepFunctionType::LINEAR)
      return start_value + (end_value - start_value) * f;

    if (type == StepFunctionType::SMOOTH)
    {
      const double p = f * f * (3.0 - 2.0 * f);
      return start_value + (end_value - start_value) * p;
    };

    if (type == StepFunctionType::PERLIN)
    {
      const double p = f * f * f * (f * (6.0 * f - 15.0) + 10.0);
      return start_value + (end_value - start_value) * p;
    };

    throw std::invalid_argument("Unsupported step function type.");
  }
}

double
StepFunction::evaluateTimeDerivative(const StepFunctionType type,
                                     const Real start_time,
                                     const double start_value,
                                     const Real end_time,
                                     const double end_value,
                                     const Real t)
{
  if (t < start_time)
  {

    // we are before _start_time - time derivative is zero
    return 0;
  }
  else if (t >= end_time)
  {

    // we are at or after _end_time - time derivative is zero
    return 0;
  }
  else
  {

    // please note: this code path is never active if _start_time
    // equals _end_time, so no need for checking

    if (type == StepFunctionType::LINEAR)
      return (end_value - start_value) / (end_time - start_time);

    if (type == StepFunctionType::SMOOTH)
    {
      Real const x = (t - start_time) / (end_time - start_time);
      return (start_value - end_value) * 6 * (-1 + x) * x;
    };

    if (type == StepFunctionType::PERLIN)
    {
      Real const x = (t - start_time) / (end_time - start_time);
      return (start_value - end_value) * -30 * (-1 + x) * (-1 + x) * x * x;
    };

    throw std::invalid_argument("Unsupported step function type.");
  }
}

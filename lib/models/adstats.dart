import 'dart:math';

import 'package:rxdart/rxdart.dart';

/// Calculate the rolling variance. See Donald Knuth’s Art of Computer Programming, Vol 2, page 232, 3rd edition or
/// https://www.johndcook.com/blog/standard_deviation/
class UsageStats {
  Stream<double> get mean => _meanSubject.scan((prevValue, value, index) => _total > 0 ? _calcMean(prevValue, value) : 0.0);

  /// higher deviation means the actions of the user are sporadic
  Stream<double> get standardDeviation => variance.map((value) => sqrt(value)); 

  Stream<double> get sum => _sumSubject.scan((prevValue, value, index) => _calcSum(prevValue, value, _meanSubject.values[_total -1], _meanSubject.values.last));

  Stream<double> get variance => sum.map((value) => _total > 1 ? (value / _total -1) : 0);

  ReplaySubject<double> _meanSubject = ReplaySubject<double>();
  BehaviorSubject<double> _sumSubject = BehaviorSubject.seeded(0);
  int _total;
  
  UsageStats() {
    _total = _meanSubject.values.length;
  }

  void add(double value) {
    _meanSubject.add(value);
    _sumSubject.add(value);
  }

  void dispose() {
    _meanSubject.close();
    _sumSubject.close();
  }

  void reset() {
    _total = 0;
  }

  double _calcMean(double prevValue, double value) => prevValue + (value - prevValue) / _total;

  double _calcSum(double prevValue, double value, double prevMean, double mean) => prevValue + (value - prevMean) * (value - mean);
}

class RollingVariance {
  double mean;

  double standardDeviation; 

  double sum;

  double variance;

  RollingVariance(this.mean, this.standardDeviation, this.sum, this.variance);
}
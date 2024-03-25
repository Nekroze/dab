package main

import "github.com/posener/complete"

type predictor func(complete.Args) []string

type predictGeneric struct {
	levels  []int
	predict predictor
}

func newGeneric(pred predictor, levels ...int) complete.Predictor {
	return predictGeneric{
		predict: pred,
		levels:  levels,
	}
}

func (p predictGeneric) activeLevel(current int) bool {
	if p.levels == nil {
		return true
	}
	for _, level := range p.levels {
		if level == current {
			return true
		}
	}

	return false
}

func (p predictGeneric) Predict(args complete.Args) []string {
	if !p.activeLevel(len(args.Completed)) {
		return nil
	}

	return p.predict(args)
}

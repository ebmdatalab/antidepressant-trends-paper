cd "C:\Users\ajwalker\Documents\GitHub\antidepressant-trends-paper\regression"
import delimited "data_for_stata.csv",clear

xtile over_65 = aged65years,nq(5)
xtile long_term_health = withalongstandinghealthcondition,nq(5)
xtile list_size_q = list_size, nq(5)
xtile fte = gp_fte_per_10000, nq(5)
xtile imd = deprivationscoreimd2015, nq(5)
xtile qof = qof_total, nq(5)
encode ruc11cd, gen(rural_urban_code)
encode principal_supplier, gen(ehr)

tabstat aged65years,by(over_65) s(min max)
tabstat withalongstandinghealthcondition,by(long_term_health) s(min max)
tabstat list_size,by(list_size_q) s(min max)
tabstat gp_fte_per_10000,by(fte) s(min max)
tabstat deprivationscoreimd2015,by(imd) s(min max)
tabstat qof_total,by(qof) s(min max)

gen single_group = 1
foreach indepvar in over_65 long_term_health list_size_q fte rural_urban_code imd qof {
	tabstat ratio,by(`indepvar') s(mean)
	meqrlogit numerator i.`indepvar' || single_group:, binomial(denominator) or
}

meqrlogit numerator i.over_65 i.long_term_health i.list_size_q i.fte i.rural_urban_code i.imd i.qof || pct: , binomial(denominator) or

predict predictions
qui corr ratio predictions
di "R-squared - fixed effects (%): " round(r(rho)^2*100,.1)

qui predict predictionsr, reffects
qui corr ratio predictionsr
di "R-squared - random effects (%): " round(r(rho)^2*100,.1)

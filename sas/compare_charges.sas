* Compare billed charges by smoking status.
* Run from the project folder after analyze.py has written output/policies.csv.
* The Satterthwaite row is the Welch test. Means should be about
* $32,050 for smokers and $8,434 for non-smokers.

proc import datafile="output/policies.csv"
    out=policies
    dbms=csv
    replace;
    getnames=yes;
    guessingrows=max;
run;

proc sql;
    select smoker,
           count(*) as policies,
           round(mean(charges), 0.01) as avg_charges
    from policies
    group by smoker
    order by avg_charges desc;

    select region,
           count(*) as policies,
           round(mean(charges), 0.01) as avg_charges
    from policies
    where smoker = "no"
    group by region
    order by avg_charges desc;
quit;

proc ttest data=policies alpha=0.05;
    class smoker;
    var charges;
run;

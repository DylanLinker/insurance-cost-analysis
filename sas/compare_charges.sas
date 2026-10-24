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

data policies_model;
    set policies;
    smoker_yes = (upcase(smoker) = "YES");
    sex_male = (upcase(sex) = "MALE");
run;

proc glm data=policies_model;
    class region;
    model charges = smoker_yes age bmi children sex_male region / solution;
run;
quit;

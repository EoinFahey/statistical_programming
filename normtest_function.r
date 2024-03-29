"""
Normscan function

Scans a data frame and produces an output to tell the
user which variables in the data frame are normally
distributed and which aren't

Author: Eoin Fahey (04/01/2023)
"""

setwd('C:/Users/Eoin/Documents/Important/Work/Github portfolio')

# Test data
data = read.csv('normscan_testdata.csv')


# Install prerequisite packages
install.packages(nortest)
library(nortest)


normscan = function(data, alpha){
    # Retrieve all numeric variables in data frame
    varnames_list = get_variable_names(data)
    
    # Filter these variables into parametric/non-parametric
    par_nonpar_list = normtest_filter(varnames_list, alpha)

    printout(par_nonpar_list, alpha)
}


    get_variable_names = function(data){
        # Create string: 'data$'
        frame_name = deparse(substitute(data))
        frame_sub = paste(frame_name, '$', sep = '')
        
        # Get list of all numeric/integer variables in data frame
        varnames_list = list()
        
        for (i in 1:NCOL(data)){
            # Create command: data$variable
            vars = data.frame(colnames(data))
            subset_string = paste(frame_sub, vars[i,], sep = '')
            varnames_list[[i]] = subset_string
            var_command = (eval(parse(text = varnames_list[[i]])))
            
            # Delete non-numeric/non-integer variables from list
            if (class(var_command) != 'numeric' & class(var_command) != 'integer'){
                varnames_list[[i]] = NULL
            }
        }
        
        # Remove null values from numeric variables list
        names(varnames_list) = seq_along(varnames_list)
        varnames_list = Filter(Negate(is.null), varnames_list)
        
        return(varnames_list)
    }


    normtest_filter = function(varnames_list, alpha){
        # Create seperate lists for parametric/non-parametric variables
        nonpar_list = list()
        par_list = list()

        # Filter variables into each list
        for (i in 1:NROW(varnames_list)){

            # Turn data$variable into a command
            call_variable = eval(parse(text = varnames_list[[i]]))
            call_variable = na.omit(call_variable)

            # Apply Shapiro test to variables n < 5000
            if ((NROW(call_variable) < 5000) & (NROW(call_variable) > 3)){
                if ((shapiro.test(call_variable)[[2]] < alpha) == FALSE) 
                    {par_list[[i]] = varnames_list[[i]]}
                if ((shapiro.test(call_variable)[[2]] < alpha) == TRUE) 
                    {nonpar_list[[i]] = varnames_list[[i]]}
            }

            # Apply Anderson-Darling test to variables n > 5000
            if (NROW(call_variable) > 4999){
                if ((ad.test(call_variable)[[2]] < alpha) == FALSE) 
                    {par_list[[i]] = varnames_list[[i]]}
                if ((ad.test(call_variable)[[2]] < alpha) == TRUE) 
                    {nonpar_list[[i]] = varnames_list[[i]]}
            }
            
        }

        par_list = par_list[!sapply(par_list,is.null)]
        nonpar_list = nonpar_list[!sapply(nonpar_list,is.null)]

        my_list_names = c("par_list", "nonpar_list")
        par_nonpar_list = list()
        
        for (i in 1:length(my_list_names)){
            par_nonpar_list[[i]] = get(my_list_names[i])
        }
        
        return(par_nonpar_list)
    }


    printout = function(par_nonpar_list, alpha){
        # R output
        cat('\nNormscan function output\n')
        cat('\n Variables n > 5000 use Anderson-Darling normality test')
        cat('\n Variables n < 5000 use Shapiro-Wilk normality test')
        cat('\n alpha =', alpha)
        cat('\n\nPARAMETRIC VARIABLES:\n')

        for (i in par_nonpar_list[[1]]){print(i)}

        cat('\n\nNON-PARAMETRIC VARIABLES:\n')

        for (i in par_nonpar_list[[2]]){print(i)}
    }


normscan(data, 0.05)

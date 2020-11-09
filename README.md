# Database Explorer for IIASA

This repository contains a set of tools to allow users explore the different IIASA datasets shown in the link below: <br />
https://iiasa.ac.at/web/home/research/researchPrograms/Energy/Databases.en.html

Please note that this tool is complementary to the IIASA own Scenario Explorer which one can use to get the data directly into MATLAB.

The repository mostly consists of two separate tools. A MATLAB API to the RESTful interface form IIASA below: <br />
https://documenter.getpostman.com/view/1057691/SWE6Zcmd#a361ba3a-9c0b-47f5-be21-58202dd6c804

and a MATLAB App that provides a graphical interface to that same API.

# Table of Contents
1. [Using the data explorer App](#using-the-data-explorer-app)
2. [Create a Connection](#creata-a-connection)
3. [Exploring the databases](#exploring-the-databases)
4. [Working with the IIASA Timeseries](#working-with-the-iiasa-timeseries)

## Using the data explorer App

The repository contains a MATLAB app that contains a visual interface to some limited access to the API. For a full "dataset" availability using the programatic way is probably a better alternative. To Launch the app, you only need to run the command below directly into MATLAB.

    IIASADataExplorer
    
![](HowTo.gif)

The app will load the NGFS scenario by default, but this can be changed at will.

## Create a Connection

Programatically, the connection to the IIASA database can be created with a default selected scenario or completely empty. To connecto to a specific scenario, please select the product name (e.g. "IXSE_NGFS"), the scheme (e.g. "IXMP Scenario Explorer SPA UI"), the environment (e.g. "ngfs"), or the product name (e.g. "NGFS Scenario Explorer"). For example:

    c = iiasa.IIASAConnection('ngfs');

At any point in time, a user can view all the available environments in the database:

    c.getEnvironments()

## Exploring the databases

Although the Connection class allows you to perform various REST calls, the best way to explore a database is to use the enviornment class:

    e = iiasa.IIASAEnvironment(c)

This object loads by default all the available Models, Scenarios, Variables, Regions and Runs in the database (not the actual timeseries). For example, you can view all the models by running:

    head(e.Variables)
    head(e.Models)

The environment also allows you to change the underlying database:

    e.changeEnvironment('iamc15');
    disp(e)

## Query datasets

There are different options to query and select timeseries within the database:

### Both Model and Scenario are known

In that case, one can request all the information from the database:

    data = e.getTimeSeries('model',"GCAM 5.2",'scenario','Current policies (Hot house world, Rep)')

However, this query can be quite length as there are many different variables and regions that will be requested. Alternatively, the data can be fildtered down by "regions" and "variables as:

    ts = e.getTimeSeries('model','AIM/CGE 2.0','scenario','ADVANCE_2020_1.5C-2100','regions','World','Variables','Emissions|CO2')

The data returned by the server is always stored in an array of IIASA Timeseries objects. Each of these objects will allow you to automatically plot the data by running:

    ts.plot('LineWidth');

### Query by variable / region:

If neither model or scenario are known, it is also possible to query the data using only the filter values, for example:

    e.changeEnvironment('ngfs');

    ts = e.getTimeSeries('variables',"Emissions|CO", 'regions', "World");
    [ts.Variable]'

    ts(1:2).plot();

For simplicity, the legend will only plot those variables that are different in each curve. For example, the previous plot have equal model, scenario, run, and region. So the legend only reports the different variable.

### Strict versus relaxed queries

By default, the queries will report any partial match to the dataset you enter. For example, the previous query returned all variables containing Emissions|CO. However, if we wanted a strict match to our inputs we could run:

    ts = e.getTimeSeries('variables',"Emissions|CO", 'regions', "World", 'strict',true);
    ts(1:2).plot();

### Filtering variables

The getTimeSeries only accepts a single "strict" command. However, we can still manually filter our results by running:

    e.filterVariables('emissions',false)
    e.filterVariables('Emissions|CO',true)

This same process can be done with regions

    e.filterRegions('japan',false)
    e.filterRegions('State of Japan',true)

and with model/scenarios to find out exact runs:

    runs = e.filterRuns('model','GCAM','scenario','immediate','strict',false);
    e.RunList(ismember(e.RunList.run_id,runs),1:8)

## Working with the IIASA Timeseries

### Plotting Data

A stack of IIASATimeseries objects can be plot in two main ways: line and bar plots. All plotting functions have two outputs: the array of graphics objects, and the legened.

#### Line Plots

The data in the object can be plotted as a set of line plots. The plot funciton accepts the exact same options as the standard plot function in MATLAB. For example:

    figure;
    ts(1:2).plot('LineWidth',2);

#### Bar Plots

Alternatively, the data in the object can also be plotted as a set of bar plots. The bar funciton accepts the exact same options as the standard bar function in MATLAB.

    figure;
    [~,l] = ts(1).bar();
    l.Location = 'northeast';

One useful utility consists in making a stack plot of several data. For example:

    figure;
    [h,l] = bar(ts(1:2),'stacked');
    l.Location = 'northeast';
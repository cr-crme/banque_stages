// ignore_for_file: non_constant_identifier_names
import 'dart:convert';

import 'package:flutter/cupertino.dart';

import './job_sst.dart';
import './skill_sst.dart';
import './risk_sst.dart';

//Remove after connection to DB
import './temporary_proxy_data.dart';

/*
* The class ProxySST contains two statics methods
* riskList() fetches the risks data from the database and transforms it into a
* list of RiskSST objects.
*
* jobList() fetches the jobs data from the database. It then does a recursive
* reading of the JSON. It creates and fills JobSST objects from the data: name,
* name of the category, code, etc. It saves questions as a list of int, if their
* value is true. Then, for each skill, it will create a skill object, and fill
* it in the same way (name, code, a list of string for criterias and another one
* for tasks). Then, for each risk in the skill, if the value is true, it will 
* search for the corresponding risk object in the previously mentionned riskList
* (generated by riskList()). It will catch the error if the risk does not exist 
* in the database. It will then return a list of jobs containing all the data.
*
* The methods currently get their data from hardcoded strings, but this will be
* replaced with fetches from the database.
*/

void main() {
  debugPrint("Testing proxy: risks");
  List<RiskSST> riskList = risksProxy().getList();
  for (RiskSST risk in riskList) {
    debugPrint(risk.toString());
  }
  print("Testing proxy: jobs");
  List<JobSST> jobList = jobsProxy().getList();
  for (JobSST job in jobList) {
    print(job);
  }
}

class risksProxy {
  risksProxy();
  //Importing and transforming json string into list of maps
  var parsedRisks = jsonDecode(riskData); //['risks'] as List

  //Transforming maps into list of objects
  fromJson(Map<String, dynamic> riskList) {
    List<RiskSST> risks = <RiskSST>[];
    for (Map<String, dynamic> risk in riskList.values) {
      final int id = risk['id'] as int;
      final String shortname = risk['shortname'] as String;
      final String title = risk['name'] as String;
      final String desc = risk['description'] as String;
      final String image = risk['image'] as String;
      risks.add(RiskSST(
          id: id,
          shortname: shortname,
          title: title,
          desc: desc,
          image: image));
    }
    return risks;
  }

  List<RiskSST> getList() {
    return fromJson(parsedRisks);
  }
}

class jobsProxy {
  jobsProxy();

  //Importing and transforming json string into map
  Map<String, dynamic> parsedJobs = jsonDecode(jobsData);
  List<JobSST> jobList = <JobSST>[];

  //Reading categories
  fromJson(Map<String, dynamic> categories) {
    //For each category
    for (Map<String, dynamic> category in categories.values) {
      String categoryName = category['name'] as String; //Save category name

      //Generate map of jobs
      Map<String, dynamic> jobs = category['jobs'] as Map<String, dynamic>;
      //For each job
      for (Map<String, dynamic> job in jobs.values) {
        String jobName = job['name'] as String; //Save job name
        String jobCode = job['code'] as String; //Save job code

        //Generate map of questions
        Map<String, dynamic> questions =
            job['questions'] as Map<String, dynamic>;

        //Save questions as int list
        List<int> jobQuestions = <int>[];
        for (MapEntry<String, dynamic> question in questions.entries) {
          //If question is true
          if (question.value) {
            jobQuestions.add(int.parse(question.key)); //Save question number
          }
        }

        //Generate map of skills
        Map<String, dynamic> skills = job['skills'] as Map<String, dynamic>;
        List<SkillSST> skillList = <SkillSST>[];

        //For each skill
        for (Map<String, dynamic> skill in skills.values) {
          String skillName = skill['name'] as String; //Save skill name
          String skillCode = skill['code'] as String; //Save skill job

          //Save criterias as string list
          List<String> skillCriterias = (skill['criteria'] as List)
              .map((item) => item as String)
              .toList();
          //Save tasks as string list
          List<String> skillTasks =
              (skill['tasks'] as List).map((item) => item as String).toList();

          //Generate map of risks
          Map<String, dynamic> skillRisks =
              skill['risks'] as Map<String, dynamic>;
          Map<String, bool> skillRisksList = {};

          //For each risk
          for (MapEntry<String, dynamic> risk in skillRisks.entries) {
            //If the risk is true
            if (risk.value) {
              try {
                //Try adding the corresponding risk object from riskList
                skillRisksList[risk.key.toString()] = risk.value;
              } catch (error) {
                //Catch if risk card is not in database
                debugPrint("risk " + risk.key + " does not exist in risk data");
              }
            }
          }
          //Add new SkillSST in skill list from data
          skillList.add(SkillSST(
              name: skillName,
              code: int.parse(skillCode),
              criterias: skillCriterias,
              tasks: skillTasks,
              risks: skillRisksList));
        }
        //Add new JobSST in job list from data
        jobList.add(JobSST(
            code: int.parse(jobCode),
            name: jobName,
            skills: skillList,
            questions: jobQuestions,
            category: categoryName));
      }
    }
    return jobList;
  }

  List<JobSST> getList() {
    return fromJson(parsedJobs);
  }
}

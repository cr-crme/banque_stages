// ignore_for_file: non_constant_identifier_names, prefer_interpolation_to_compose_strings
import 'dart:convert';

import './job_sst.dart';
import './skill_sst.dart';
import 'risk.dart';
import 'temporary_proxy_data.dart';
//Remove after connection to DB

/* 
* The class cardsProxy() fetches risks data from the database and transforms them
* into a list of cards objects. It returns with the list with the method getList().
*
* The class jobsProxy() fetches the jobs data from the database. It creates and
* fills JobSST objects from the data: name, name of the category, code, etc.
* It saves questions as a list of int, if their value is true. Then, for each
* skill, it will create a skill object, and fill it in the same way (name, code,
* a list of string for criterias and another one for tasks). I will then return
* a list of jobs containing all the data.
*
* The methods currently get their data from hardcoded strings, but this will be
* replaced with fetches from the database.
*/

/* class CardsProxy {
  CardsProxy();
  //Importing and transforming json string into list of maps
  Map<String, dynamic> parsedRisks = jsonDecode(riskData);

  //Transforming maps into list of objects
  fromJson(Map<String, dynamic> cards) {
    //Create a cards array, then for each card
    List<Risk> cardsList = <Risk>[];
    for (MapEntry<String, dynamic> card in cards.entries) {
      //Save informations
      final int cardID = int.parse(card.key); //Save key as the id
      final String cardShortname = card.value['shortname'] as String;
      final String cardName = card.value['name'] as String;

      //Put risks in a map, then for each risk
      Map<String, dynamic> risks = card.value['risks'] as Map<String, dynamic>;
      List<SubRisk> riskList = [];
      for (MapEntry<String, dynamic> risk in risks.entries) {
        final int riskID = int.parse(risk.key); //Save key as ID
        final String riskTitle = risk.value['title'] as String;
        final String riskIntro = risk.value['intro'] as String;
        //Save list of images as list of strings
        final List<String> images = (risk.value['images'] as List)
            .map((item) => item as String)
            .toList();
        //For each situation
        Map<String, List<String>> riskSituations = {};
        final Map<String, dynamic> situations =
            risk.value['situations'] as Map<String, dynamic>;
        for (MapEntry<String, dynamic> situation in situations.entries) {
          //Save key as the line
          final String situationLine = situation.key;
          //Save corresponding string list as the sublines (will often be emtpy)
          final List<String> situationSublines =
              (situation.value as List).map((item) => item as String).toList();
          riskSituations[situationLine] = situationSublines;
        }
        //For each factor, do the same
        Map<String, List<String>> riskFactors = {};
        final Map<String, dynamic> factors =
            risk.value['factors'] as Map<String, dynamic>;
        for (MapEntry<String, dynamic> factor in factors.entries) {
          final String factorLine = factor.key;
          final List<String> factorSublines =
              (factor.value as List).map((item) => item as String).toList();
          riskFactors[factorLine] = factorSublines;
        }
        //For each symptom, do the same
        Map<String, List<String>> riskSymptoms = {};
        final Map<String, dynamic> symptoms =
            risk.value['symptoms'] as Map<String, dynamic>;
        for (MapEntry<String, dynamic> symptom in symptoms.entries) {
          final String symptomLine = symptom.key;
          final List<String> symptomSublines =
              (symptom.value as List).map((item) => item as String).toList();
          riskSymptoms[symptomLine] = symptomSublines;
        }
        //Put everything in a risk object and add to the list of risks
        riskList.add(SubRisk(
            id: riskID,
            title: riskTitle,
            intro: riskIntro,
            situations: riskSituations,
            factors: riskFactors,
            symptoms: riskSymptoms,
            images: images));
      }
      //For each link
      List<RiskLink> cardLinks = [];
      final Map<String, dynamic> links =
          card.value['links'] as Map<String, dynamic>;
      for (Map<String, dynamic> link in links.values) {
        final String linkSource = link['source'] as String;
        final String linkTitle = link['title'] as String;
        final String linkURL = link['url'] as String;
        //Save link infos into link object, add to link list
        cardLinks
            .add(RiskLink(source: linkSource, title: linkTitle, url: linkURL));
      }
      //Save everything into a card object, add to list of cards
      cardsList.add(Risk(
        //id: cardID,
        shortname: cardShortname,
        name: cardName,
        subrisks: riskList,
        links: cardLinks,
      ));
    }
    return cardsList;
  }

  List<Risk> getList() {
    return fromJson(parsedRisks);
  }
}
 */
/*
class JobsProxy {
  JobsProxy();

  //Importing and transforming json string into map
  Map<String, dynamic> parsedJobs = jsonDecode(jobsData);

  //Reading categories
  fromJson(Map<String, dynamic> categories) {
    List<JobSST> jobList = <JobSST>[];
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
          Map<String, bool> skillRisksMap = {};

          //For each risk
          for (MapEntry<String, dynamic> risk in skillRisks.entries) {
            //If the risk is true
            if (risk.value) {
              //adding it to the map
              skillRisksMap[risk.key.toString()] = risk.value;
            }
          }
          //Add new SkillSST in skill list from data
          skillList.add(SkillSST(
              name: skillName,
              code: int.parse(skillCode),
              criterias: skillCriterias,
              tasks: skillTasks,
              risks: skillRisksMap));
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
*/
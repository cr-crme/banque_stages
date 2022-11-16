import 'package:flutter/widgets.dart';

import 'common/job_sst.dart';
import 'common/risk.dart';
import 'common/skill_sst.dart';
import 'common/proxy_ref_sst.dart';
import 'sst_cards/widgets/sst_card.dart';

class SSTCache {
  static final SSTCache _sstCache = SSTCache._internal();

  List<JobSST> jobs = JobsProxy().getList();
  List<Risk> risks = CardsProxy().getList();

  factory SSTCache() {
    return _sstCache;
  }

  SSTCache._internal();

  List<JobSST> getJobs() {
    return jobs;
  }

  List<Risk> getRisks() {
    return risks;
  }

  ListView getListViewJob() {
    return ListView(
        children: [for (JobSST job in jobs) SSTCard(job.code, job.name)]);
  }

  ListView getListViewRisk() {
    return ListView(
        children: [for (Risk risk in risks) SSTCard(risk.id, risk.name)]);
  }

  void refresh() {
    jobs = JobsProxy().getList();
    risks = CardsProxy().getList();
  }
}

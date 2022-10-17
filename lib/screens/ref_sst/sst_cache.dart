import 'package:flutter/widgets.dart';

import 'common/job_sst.dart';
import 'common/risk_sst.dart';
import 'common/skill_sst.dart';
import 'common/proxy_ref_sst.dart';
import 'sst_cards/widgets/sst_card.dart';

class SSTCache {
  static final SSTCache _sstCache = SSTCache._internal();

  List<JobSST> jobs = ProxySST().getJobList();
  List<RiskSST> risks = ProxySST().getRiskList();

  factory SSTCache() {
    return _sstCache;
  }

  SSTCache._internal();

  List<JobSST> getJobs() {
    return jobs;
  }

  List<RiskSST> getRisks() {
    return risks;
  }

  ListView getListViewJob() {
    return ListView(
        children: [for (JobSST job in jobs) SSTCard(job.jobCode, job.jobName)]);
  }

  ListView getListViewRisk() {
    return ListView(children: [
      for (RiskSST risk in risks) SSTCard(risk.cardID, risk.title)
    ]);
  }
}

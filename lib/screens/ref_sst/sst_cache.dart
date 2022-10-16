import 'common/job_sst.dart';
import 'common/risk_sst.dart';
import 'common/skill_sst.dart';
import 'common/proxy_ref_sst.dart';

class Singleton {
  static final Singleton _singleton = Singleton._internal();

  List<JobSST> jobs = ProxySST.jobList();
  List<RiskSST> risks = ProxySST.riskList();

  factory Singleton() {
    return _singleton;
  }

  Singleton._internal();
}

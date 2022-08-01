import 'package:flutter/material.dart';

import '/common/models/enterprise.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({
    Key? key,
    required this.enterprise,
  }) : super(key: key);

  final Enterprise enterprise;

  @override
  State<JobsPage> createState() => JobsPageState();
}

class JobsPageState extends State<JobsPage> {
  late String _expandedJobId = widget.enterprise.jobs.first.id;

  void addJob() {}

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ExpansionPanelList(
        expansionCallback: (index, _) =>
            setState(() => _expandedJobId = widget.enterprise.jobs[index].id),
        children: widget.enterprise.jobs
            .map((job) => ExpansionPanel(
                canTapOnHeader: true,
                isExpanded: _expandedJobId == job.id,
                headerBuilder: (context, isExpanded) => ListTile(
                      title: Text(
                        job.specialization,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                body: const Text("")))
            .toList(),
      ),
    );
  }
}

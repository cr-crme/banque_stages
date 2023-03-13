import 'package:flutter/material.dart';

import '/common/models/student.dart';
import '/common/models/visiting_priority.dart';
import '/common/providers/students_provider.dart';
import '/common/widgets/main_drawer.dart';

class SupervisionChart extends StatefulWidget {
  const SupervisionChart({super.key});

  @override
  State<SupervisionChart> createState() => _SupervisionChartState();
}

class _SupervisionChartState extends State<SupervisionChart> {
  bool _isSearchBarExpanded = false;
  final _searchTextController = TextEditingController();

  void _toggleSearchBar() {
    _isSearchBarExpanded = !_isSearchBarExpanded;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final iconSize = screenSize.width / 16;

    // TODO: Get student of the current teacher
    final studentsTp = StudentsProvider.of(context);
    List<Student> students = studentsTp
        .map<Student?>((e) => _searchTextController.text == ''
            ? e
            : e.name
                    .toLowerCase()
                    .contains(_searchTextController.text.toLowerCase())
                ? e
                : null)
        .where((e) => e != null)
        .toList()
        .cast<Student>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Élèves à superviser'),
        bottom: PreferredSize(
            preferredSize: Size(screenSize.width, iconSize * 1.5),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _TabIcon(
                      screenSize: screenSize,
                      iconSize: iconSize,
                      onTap: () {},
                      icon: Icons.transfer_within_a_station),
                  _TabIcon(
                      screenSize: screenSize,
                      iconSize: iconSize,
                      onTap: _toggleSearchBar,
                      icon: Icons.search),
                  _TabIcon(
                      screenSize: screenSize,
                      iconSize: iconSize,
                      onTap: () {},
                      icon: Icons.filter_alt_sharp),
                ])),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_isSearchBarExpanded)
              Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: TextFormField(
                  decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      labelText: 'Rechercher un métier',
                      suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _searchTextController.text = ''),
                          icon: const Icon(Icons.clear)),
                      border:
                          const OutlineInputBorder(borderSide: BorderSide())),
                  controller: _searchTextController,
                  onChanged: (value) => setState(() {}),
                ),
              ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: students.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: ((ctx, i) {
                final internship = students[i].internships.isNotEmpty
                    ? students[i].internships.last
                    : null;
                return _StudentTile(
                  key: Key(students[i].id),
                  name: students[i].name,
                  job: internship ?? 'Aucun stage', // TODO verify that
                  business: internship ?? 'Aucun stage', // TODO verify that
                  priority: VisitingPriority.low,
                  avatar: const CircleAvatar(),
                );
              }),
            ),
          ],
        ),
      ),
      drawer: const MainDrawer(),
    );
  }
}

class _TabIcon extends StatelessWidget {
  const _TabIcon({
    Key? key,
    required this.screenSize,
    required this.iconSize,
    required this.icon,
    this.onTap,
  }) : super(key: key);

  final Size screenSize;
  final double iconSize;
  final IconData icon;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: screenSize.width / 3,
        height: iconSize * 1.5,
        child: Icon(
          icon,
          size: iconSize,
        ),
      ),
    );
  }
}

class _StudentTile extends StatelessWidget {
  const _StudentTile({
    super.key,
    required this.name,
    required this.business,
    required this.avatar,
    required this.job,
    required this.priority,
  });

  final String name;
  final String business;
  final Widget avatar;
  final String job;
  final VisitingPriority priority;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: ListTile(
        leading: SizedBox(
          height: double.infinity, // This centers the avatar
          child: avatar,
        ),
        title: Text(name),
        isThreeLine: true,
        subtitle: Text(
          '$business\n$job',
          maxLines: 2,
          style: const TextStyle(color: Colors.black87),
        ),
        trailing: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 5.0,
                spreadRadius: 0.0,
                offset: Offset(2.0, 2.0),
              )
            ],
            border: Border.all(color: Colors.lightBlue, width: 3),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () {},
            alignment: Alignment.center,
            icon: Icon(
              priority.icon,
              color: priority.color,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}

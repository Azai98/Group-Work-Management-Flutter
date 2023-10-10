import 'package:collab/personal_spaces/statistics/stats_bar_chart.dart';
import 'package:collab/personal_spaces/statistics/stats_grid.dart';
import 'package:flutter/material.dart';

class StatsScreen extends StatefulWidget {
  final String projectID;
  const StatsScreen({Key? key, required this.projectID}) : super(key: key);

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar:  AppBar(
        centerTitle: true,
        title : const Text("Project Statistics", style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: true,
      ),
      body: Container(
              decoration: BoxDecoration(
              image: DecorationImage(
              image: AssetImage('assets/images/personalspaces-ui.webp'),
              fit: BoxFit.cover)),
        child: Container(
        padding: EdgeInsets.only(top: 100),
        alignment: Alignment.center,
        width: double.maxFinite,
        decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.bottomCenter, colors: [
        Colors.black.withOpacity(0.8),
        Colors.black.withOpacity(0.7)
        ])),
        child: CustomScrollView(
        physics: ClampingScrollPhysics(),
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            sliver: SliverToBoxAdapter(
              child: StatsGrid(projectID: widget.projectID),
            ),
          ),
          _buildHeader(),
          SliverPadding(
            padding: const EdgeInsets.only(top: 5.0),
            sliver: SliverToBoxAdapter(
              child: statChart(projectID: widget.projectID)
            ),
          ),

        ],
      ),))
    );
  }
}

SliverPadding _buildHeader() {
  return SliverPadding(
    padding: const EdgeInsets.only(left:20, right: 20, bottom: 10, top: 20),
    sliver: SliverToBoxAdapter(
      child: Text(
        'Project Graph',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 25.0,
          decoration: TextDecoration.underline,
          fontFamily: 'Raleway',
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

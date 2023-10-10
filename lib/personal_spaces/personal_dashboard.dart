import 'package:collab/personal_spaces/calender_schedule.dart';
import 'package:collab/personal_spaces/archives/project_archive_list.dart';
import 'package:collab/personal_spaces/project_report_list.dart';
import 'package:collab/personal_spaces/user_checklist.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class personalDashboard extends StatelessWidget {

  Items item1 = Items(
      title: "User Checklist",
      subtitle: "Your Personal Spaces",
      img: "assets/images/todo.png");

  Items item2 = Items(
    title: "Calendar &\n Schedule",
    subtitle: "Your Time Manager",
    img: "assets/images/calendar.png",
  );
  Items item3 = Items(
    title: "Project Summary Statistics",
    subtitle: "Your Summary Assistant",
    img: "assets/images/report.png",
  );

  Items item4 = Items(
    title: "Project & Task Archive",
    subtitle: "Your Further Review",
    img: "assets/images/archives.png",
  );

  personalDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Items> myList = [item1, item2];
    var report = item3;
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/personalspaces-ui.webp'),
              fit: BoxFit.cover)),
      child: Container(
        padding: EdgeInsets.only(top:80),
        alignment: Alignment.center,
          width: double.maxFinite,
          decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.bottomCenter, colors: [
                Colors.black.withOpacity(0.8),
                Colors.black.withOpacity(0.7)
              ])),
            child:Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              Flexible(
              child: GridView.count(
                shrinkWrap: true,
                childAspectRatio: 1.0,
                padding: EdgeInsets.only(left: 16, right: 16),
                crossAxisCount: 2,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
                children: myList.map((data) {
                  return Container(
                    decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(10)),
                    child:
                    InkWell(
                    onTap: () {
                          data == item1 ?
                          Navigator.push(
                          context,
                          MaterialPageRoute(
                          builder: (context) =>
                          userChecklist()))
                          :
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                              builder: (context) =>
                                  calendarSchedule()));
                          },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          data.img,
                          width: 42,
                        ),
                        SizedBox(
                          height: 14,
                        ),
                        Text(
                          data.title,
                          style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          data.subtitle,
                          style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ),
                        SizedBox(
                          height: 14,
                        ),
                      ],
                    ),)
                  );
                }).toList()),
          ),
           SizedBox(height: 15),
           Container(
              width: double.maxFinite,
              margin: EdgeInsets.all(16),
              height: 150,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(10)),
            child: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            reportList()));
              },
             child:Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  item3.img,
                  width: 42,
                ),
                SizedBox(
                  height: 14,
                ),
                Text(
                  item3.title,
                  style: GoogleFonts.openSans(
                      textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  item3.subtitle,
                  style: GoogleFonts.openSans(
                      textStyle: TextStyle(
                          color: Colors.white38,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ),
                SizedBox(
                  height: 14,
                ),
              ],
            ),)
           ),
                Container(
                    width: double.maxFinite,
                    margin: EdgeInsets.all(16),
                    height: 150,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(10)),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    archiveList()));
                      },
                      child:Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            item4.img,
                            width: 42,
                          ),
                          SizedBox(
                            height: 14,
                          ),
                          Text(
                            item4.title,
                            style: GoogleFonts.openSans(
                                textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600)),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            item4.subtitle,
                            style: GoogleFonts.openSans(
                                textStyle: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ),
                          SizedBox(
                            height: 14,
                          ),
                        ],
                      ),)
                ),

           ]
         ),
      ),
    );
  }
}

class Items {
  String title;
  String subtitle;
  String img;
  Items({required this.title, required this.subtitle, required this.img});
}
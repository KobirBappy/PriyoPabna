import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fontisto_flutter/fontisto_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';
import '../common/app_config.dart';
import '../common/colors.dart';
import '../data/info_group.dart';
import '../widgets/action_button.dart';

class WhoCanDonateScreen extends StatefulWidget {
  static const route = 'who-can-donate';
  const WhoCanDonateScreen({Key key}) : super(key: key);

  @override
  State<WhoCanDonateScreen> createState() => _WhoCanDonateScreenState();
}

class _WhoCanDonateScreenState extends State<WhoCanDonateScreen> {

  final BannerAd myBanner = BannerAd(
    adUnitId: 'ca-app-pub-3940256099942544/6300978111',
    size: AdSize.banner,
    request: AdRequest(),
    listener: BannerAdListener(),
  );

  @override
  void initState() {
    super.initState();
    myBanner.load();
  }


  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context)
        .textTheme
        .headline6
        .copyWith(color: MainColors.primary);
    return Scaffold(
      appBar: AppBar(title: const Text('Who Can Donate Blood?')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ...InfoGroup.whoCanDonate
                  .map(
                    (g) => ExpansionTile(
                      title: Text(g.title, style: titleStyle),
                      initiallyExpanded: g.id == 0,
                      children: g.info
                          .map(
                            (c) => ListTile(
                              leading: const Icon(Istos.bookmark),
                              title: Text(c),
                            ),
                          )
                          .toList(),
                    ),
                  )
                  .toList(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ActionButton(
                  callback: () async {
                    if (await canLaunch(AppConfig.bloodDonationInfoLink)) {
                      launch(AppConfig.bloodDonationInfoLink,enableJavaScript: true,);
                    } else {
                      Fluttertoast.showToast(msg: 'Could not launch the link');
                    }
                  },
                  text: 'Learn More',
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        child: AdWidget(ad: myBanner,),
        height: 50,
      ),
    );
  }
}

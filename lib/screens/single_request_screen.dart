import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import '../common/colors.dart';
import '../data/blood_request.dart';

import '../utils/blood_types.dart';
import '../utils/tools.dart';

class SingleRequestScreen extends StatefulWidget {
  final BloodRequest request;
  const SingleRequestScreen({Key key, this.request}) : super(key: key);

  @override
  State<SingleRequestScreen> createState() => _SingleRequestScreenState();
}

class _SingleRequestScreenState extends State<SingleRequestScreen> {


  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final titleStyle = textTheme.caption.copyWith(fontSize: 14);
    final bodyStyle = textTheme.bodyText1.copyWith(fontSize: 16);
    const bodyWrap = EdgeInsets.only(top: 4, bottom: 16);

    return Scaffold(
      appBar: AppBar(title: const Text('Blood Request Details')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Submitted By', style: titleStyle),
              Padding(
                padding: bodyWrap,
                child: Text(
                  '${widget.request.submittedBy} on ${Tools.formatDate(widget.request.submittedAt)}',
                  style: bodyStyle,
                ),
              ),
              Text('Patient Name', style: titleStyle),
              Padding(
                padding: bodyWrap,
                child: Text(widget.request.patientName ?? '', style: bodyStyle),
              ),
              Text('Location', style: titleStyle),
              Padding(
                padding: bodyWrap,
                child: Text(
                  '${widget.request.medicalCenter.name} - ${widget.request.medicalCenter.location}',
                  style: bodyStyle,
                ),
              ),
              Text('Blood Type', style: titleStyle),
              Padding(
                padding: bodyWrap,
                child: Text(widget.request.bloodType.name ?? '', style: bodyStyle),
              ),
              Text('Possible Donors', style: titleStyle),
              Padding(
                padding: bodyWrap,
                child: Text(
                    widget.request.bloodType.possibleDonors
                        .map((e) => e.name)
                        .join('   /   '),
                    style: bodyStyle),
              ),
              if (!Tools.isNullOrEmpty(widget.request.note)) ...[
                Text('Notes', style: titleStyle),
                Padding(
                  padding: bodyWrap,
                  child: Text(widget.request.note, style: bodyStyle),
                ),
              ],
              const SizedBox(height: 16),
              const Divider(thickness: 1),
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all(
                            MainColors.primaryDark,
                          ),
                        ),
                        onPressed: () async {
                          final url = 'https://www.google.com/maps/search/'
                              '?api=1&query=${widget.request.medicalCenter.latitude},'
                              '${widget.request.medicalCenter.longitude}';
                          if (await canLaunch(url) != null) {
                            launch(url);
                          } else {
                            Fluttertoast.showToast(msg: 'Could not launch map');
                          }

                        },
                        icon: const Icon(Icons.navigation),
                        label: const Text('Get Directions'),
                      ),
                    ),
                    const VerticalDivider(thickness: 1),
                    Expanded(
                      child: TextButton.icon(
                        style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all(
                            MainColors.primaryDark,
                          ),
                        ),
                        onPressed: () {
                          Share.share(
                            'Emergency Request!\n\n'
                            '${widget.request.patientName} needs ${widget.request.bloodType.name} '
                            'blood by ${Tools.formatDate(widget.request.requestDate)}.\n'
                            'You can donate by visiting ${widget.request.medicalCenter.name} located in '
                            '${widget.request.medicalCenter.location}.\n\n'
                            'Contact +88${widget.request.contactNumber} for more info.\n\n'
                            'By Priyo Pabna App',
                          );
                        },
                        icon: const Icon(Icons.share),
                        label: const Text('Share'),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(thickness: 1),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 24,
                ),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      MainColors.primary,
                    ),
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.all(12),
                    ),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    )),
                  ),
                  onPressed: () async {
                    final contact = 'tel:+88${widget.request.contactNumber}';
                    if (await canLaunch(contact)) {
                      launch(contact);
                    } else {
                      Fluttertoast.showToast(msg: 'Something wrong happened');
                    }
                  },
                  child: Center(
                    child: Text(
                      'Contact',
                      textAlign: TextAlign.center,
                      style: textTheme.subtitle1.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
              if (!widget.request.isFulfilled &&
                  widget.request.uid == FirebaseAuth.instance.currentUser.uid)
                _MarkFulfilledBtn(request: widget.request),
            ],
          ),
        ),
      ),
    );
  }
}

class _MarkFulfilledBtn extends StatefulWidget {
  final BloodRequest request;

  const _MarkFulfilledBtn({Key key, this.request}) : super(key: key);

  @override
  _MarkFulfilledBtnState createState() => _MarkFulfilledBtnState();
}

class _MarkFulfilledBtnState extends State<_MarkFulfilledBtn> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: CircularProgressIndicator()),
          )
        : Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  Colors.green[600],
                ),
                padding: MaterialStateProperty.all(
                  const EdgeInsets.all(12),
                ),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                )),
              ),
              onPressed: () async {
                setState(() => _isLoading = true);
                try {
                  await FirebaseFirestore.instance
                      .collection('blood_requests')
                      .doc(widget.request.id)
                      .update({'isFulfilled': true});
                  widget.request.isFulfilled = true;
                  Navigator.pop(context);
                } on FirebaseException catch (e) {
                  Fluttertoast.showToast(msg: e.message);
                } catch (e) {
                  Fluttertoast.showToast(
                    msg: 'Something went wrong. Please try again',
                  );
                }
                setState(() => _isLoading = false);
              },
              child: Center(
                child: Text(
                  'Mark as Fulfilled',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1
                      .copyWith(color: Colors.white),
                ),
              ),
            ),
          );
  }
}

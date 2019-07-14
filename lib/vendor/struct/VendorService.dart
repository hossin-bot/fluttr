import 'package:flutter/material.dart';
import 'package:kamino/animation/transition.dart';
import 'package:kamino/models/movie.dart';
import 'package:kamino/models/source.dart';
import 'package:kamino/models/tv_show.dart';
import 'package:kamino/ui/interface.dart';
import 'package:kamino/util/settings.dart';
import 'package:kamino/vendor/view/SearchingSourcesDialog.dart';
import 'package:kamino/vendor/view/SourceSelectionView.dart';
import 'package:meta/meta.dart';

abstract class VendorService {

  final bool isNetworkService;
  final bool allowSourceSelection;

  List<Function> onUpdateEvents;
  VendorServiceStatus status;
  List<SourceModel> _sourceList;

  List<SourceModel> get sourceList => _sourceList;

  VendorService({
    @required this.isNetworkService,
    @required this.allowSourceSelection
  }) :
    status = VendorServiceStatus.IDLE,
    onUpdateEvents = new List(),
    _sourceList = new List();

  ///
  /// Adds a source model to the list and triggers all
  /// update events.
  ///
  void addSource(SourceModel model){
    _sourceList.add(model);
    triggerUpdate();
  }

  ///
  /// Clears the source list. (Usually in preparation to search for something
  /// else.)
  ///
  void clearSourceList(){
    _sourceList.clear();
    triggerUpdate();
  }

  ///
  /// Adds a function to the event list that should be called
  /// every time an update is triggered.
  ///
  void addUpdateEvent(Function onUpdate){
    onUpdateEvents.add(onUpdate);
  }

  ///
  /// A method that should only be used internally by vendor service
  /// definitions.
  ///
  /// This is used to indicate that an update should be triggered.
  ///
  void triggerUpdate() {
    for (Function onUpdate in onUpdateEvents)
      try { onUpdate(); } catch(ex){}
  }

  Future<void> playMovie(MovieContentModel movie, BuildContext context);
  Future<void> playTVShow(
    TVShowContentModel show,
    int seasonNumber,
    int episodeNumber,
    BuildContext context
  );

  Future<bool> initialize(BuildContext context);

  ///
  /// This method will be called in order to authenticate with the vendor API.
  /// All keys generated by this method should be stored internally.
  /// However, they will not be used until this has completed.
  ///
  /// This method returns a [bool] to determine whether authentication was
  /// successful.
  ///
  Future<bool> authenticate(BuildContext context);

  Future<bool> _sourceSelectionEnabled() async {
    return allowSourceSelection && await (Settings.manuallySelectSourcesEnabled);
  }

  Future<void> done(BuildContext context);

  ///
  /// Updates the status of the [VendorService].
  /// Triggers all update events, when the status is updated, as well as
  /// handling any necessary actions when the state is changed.
  ///
  Future<void> setStatus(BuildContext context, VendorServiceStatus status, { String title }) async {
    VendorServiceStatus oldStatus = this.status;

    if(oldStatus == status) return;

    // Handle setting the status, i.e. showing or hiding dialogs, etc.
    switch(status){
      case VendorServiceStatus.IDLE:
        if(oldStatus == VendorServiceStatus.DONE){
          Navigator.of(context).pop();
          break;
        }

        if(oldStatus == VendorServiceStatus.PROCESSING){
          await done(context);
        }

        Navigator.of(context).pop();
        break;
      case VendorServiceStatus.INITIALIZING:
        if(oldStatus == VendorServiceStatus.IDLE){
          Interface.showConnectingDialog(context, onPop: () => {
            this.setStatus(context, VendorServiceStatus.IDLE)
          });
        }
        break;
      case VendorServiceStatus.PROCESSING:
        if(oldStatus == VendorServiceStatus.INITIALIZING ||
            oldStatus == VendorServiceStatus.AUTHENTICATING){
          (() async {
            bool showSourceSelect = await _sourceSelectionEnabled();

            if(showSourceSelect){
              Navigator.of(context).pushReplacement(ApolloTransitionRoute(
                  builder: (BuildContext context) => SourceSelectionView(
                      title: title,
                      service: this
                  ))
              );
            }else{
              Navigator.of(context).pop();

              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (_) => WillPopScope(
                    child: SearchingSourcesDialog(onCancel: () async {
                      setStatus(context, VendorServiceStatus.IDLE);
                    }),
                    onWillPop: () async {
                      setStatus(context, VendorServiceStatus.IDLE);
                      return false;
                    },
                  )
              );
            }

          })();
        }
        break;
      case VendorServiceStatus.DONE:
        if(oldStatus == VendorServiceStatus.PROCESSING)
          await done(context);

        break;
      default:
        break;
    }

    this.triggerUpdate();
    this.status = status;
  }

}

enum VendorServiceStatus {

  /// If the service is not performing any action, AND the app is NOT
  /// authenticated with the service, this status should be used.
  /// This is the default [VendorServiceStatus].
  IDLE,

  /// This status should be used whilst the service is preparing to connect.
  /// For example, when performing checks to see if the service
  /// is online.
  ///
  /// THIS IS NOT FOR AUTHENTICATION. For that, you should use
  /// [VendorServiceStatus.AUTHENTICATING] instead.
  INITIALIZING,

  /// This status is used whilst performing authentication checks with the
  /// service.
  ///
  /// If authentication fails, the status should be returned to
  /// [VendorServiceStatus.IDLE] and an error should be shown.
  ///
  /// If authentication succeeds, the status should be set to
  /// [VendorServiceStatus.PROCESSING] or [VendorServiceStatus.IDLE], as
  /// applicable.
  AUTHENTICATING,

  /// When the service is performing an action, such as searching for content,
  /// this status should be used.
  PROCESSING,

  /// When the service has completed an action BUT the result has not yet
  /// been used, this status should be DONE.
  /// Once the result has been used, the status can then be set to
  /// [VendorServiceStatus.IDLE].
  DONE

}
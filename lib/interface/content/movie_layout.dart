import 'package:flutter/material.dart';
import 'package:kamino/generated/i18n.dart';
import 'package:kamino/main.dart';
import 'package:kamino/models/movie.dart';

class MovieLayout {

  static Widget generate(BuildContext context, MovieContentModel _data){
    return Container();
  }

  ///
  /// applyTransformations() -
  /// Allows this layout to apply transformations to the overview scaffold.
  /// This should be used to add a play FAB, for example.
  ///
  static Widget getFloatingActionButton(BuildContext context, MovieContentModel movie){
    return null;

    /*return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: new Row(
            children: <Widget>[
              Expanded(
                  child: new FloatingActionButton.extended(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)
                      ),
                      onPressed: () async {
                        KaminoAppState application = context.ancestorStateOfType(const TypeMatcher<KaminoAppState>());
                        (await application.getPrimaryVendorService()).playMovie(
                            movie,
                            context
                        );
                      },
                      icon: Container(),
                      label: Text(
                        S.of(context).play_movie,
                        style: TextStyle(
                            letterSpacing: 0.0,
                            fontFamily: 'GlacialIndifference',
                            fontSize: 18.0,
                            color: Theme.of(context).accentTextTheme.body1.color
                        ),
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                      elevation: 30
                  )
              )
            ]
        )
    );*/
  }

}
import React from 'react';
import ReactNative from 'react-native';
import MWMMapView from '../../shared/native/MWMMapView';
import ActionBar from '../../shared/feature_view/ActionBar';
import FeatureViewContainer from './FeatureViewContainer';
import ViewState from './FeatureViewState';
import Utils from '../../shared/Utils';

const Animated = ReactNative.Animated;
const StyleSheet = ReactNative.StyleSheet;
const View = ReactNative.View;

export default class FeatureViewPopup extends React.Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    feature: React.PropTypes.object,
    onDismiss: React.PropTypes.func.isRequired,
    location: React.PropTypes.object,
    addBookmark: React.PropTypes.func.isRequired,
    removeBookmark: React.PropTypes.func.isRequired,
  };

  constructor(props) {
    super(props);
    this.state = {
      featureTop: new Animated.Value(0),
      actionTop: new Animated.Value(0),
      viewState: ViewState.HIDDEN,
    };
    this._headerHeight = 125;
    this.state.featureTop.addListener(({ value }) => {
      this.featureTopValue = value;
    });
  }

  componentWillMount() {
    this.panResponder = new Utils.PanResponderWrapper({
      getStartValue: () => this.featureTopValue,
      onPanResponderMove: (evt, gestureState, startY) => {
        const newY = startY + gestureState.dy;
        this.state.featureTop.setValue(Math.max(newY, -(this.height - 100)));
      },
      onPanResponderRelease: (evt, gestureState) => {
        if (this.state.viewState === ViewState.HEADER) {
          if (gestureState.vy < -0.01 || gestureState.dy < -10) { // swipe up or dragged 10px up
            this._expand();
          } else if (gestureState.vy > 0.01 || gestureState.dy > 10) { // swipe or dragged down
            this._popDown();
          } else {
            this._popToHeader();
          }
        } else if (this.state.viewState === ViewState.EXPANDED) {
          const expandPoint = -(Math.min(this.height, 600) - 100);
          if (this.featureTopValue > -100) {
            this._popDown();
          } else if (this.featureTopValue > expandPoint) {
            this._popToHeader();
          } else if (gestureState.vy >= 1) {
            this._expand();
          }
        }
      },
      onPanResponderTerminate: startY => this.state.featureTop.setValue(startY),
    });
  }

  componentWillReceiveProps(newProps) {
    if (newProps.feature === null && this.props.feature !== null) {
      this._popDown();
    } else if (newProps.feature !== this.props.feature) {
      this._popToHeader();
    }
  }

  _popToHeader() {
    Utils.animateTo(this.state.featureTop, 150, -this._headerHeight);
    Utils.animateTo(this.state.actionTop, 150, -47);
    this.setState({ viewState: ViewState.HEADER });
  }

  _popDown() {
    Utils.animateTo(this.state.featureTop, 100, 0);
    Utils.animateTo(this.state.actionTop, 100, 0);
    MWMMapView.deactivateMapSelection();
    this.setState({ viewState: ViewState.HIDDEN });
    if (this.props.feature) {
      this.props.onDismiss();
    }
  }

  _expand = () => {
    const expandPoint = -(Math.min(this.height, 600) - 100);
    Utils.animateTo(this.state.featureTop, 150, expandPoint);
    this.setState({ viewState: ViewState.EXPANDED });
  };

  _headerClicked = () => {
    if (this.state.viewState === ViewState.HEADER) {
      this._expand();
    } else {
      this._popToHeader();
    }
  };

  _headerHeightUpdated = (newHeight) => {
    const oldHeight = this._headerHeight;
    this._headerHeight = Math.max(125, newHeight + 47);
    if (oldHeight !== this._headerHeight && this.state.viewState === ViewState.HEADER) {
      this._popToHeader();
    }
  };

  render() {
    return (
      <View>
        <Animated.View
          style={[{ top: this.state.featureTop }, styles.floatingContainer]}
          onLayout={(event) => {
            const oldHeight = this.height;
            this.height = event.nativeEvent.layout.height;
            if (this.state.viewState === ViewState.EXPANDED && this.height < oldHeight) {
              this._expand();
            }
          }}
        >
          <FeatureViewContainer
            feature={this.props.feature} location={this.props.location} collapseHours={this._expand}
            panHandlers={this.panResponder.panHandlers()} headerClicked={this._headerClicked}
            headerHeightUpdated={this._headerHeightUpdated} viewState={this.state.viewState}
          />
        </Animated.View>
        <Animated.View style={[{ top: this.state.actionTop }, styles.floatingContainer]}>
          <ActionBar
            feature={this.props.feature}
            addBookmark={this.props.addBookmark} removeBookmark={this.props.removeBookmark}
          />
        </Animated.View>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  floatingContainer: {
    position: 'absolute',
    left: 0,
    right: 0,
  },
});

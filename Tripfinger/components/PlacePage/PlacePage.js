import React from 'react';
import ReactNative from 'react-native';
import MWMMapView from '../MWMMapView';
import ActionBar from './ActionBar';
import PlacePageInfo from './PlacePageInfo';
import ViewState from './PlacePageViewState';
import Utils from '../../modules/Utils';

const Component = React.Component;
const PropTypes = React.PropTypes;
const Animated = ReactNative.Animated;
const StyleSheet = ReactNative.StyleSheet;
const View = ReactNative.View;

export default class PlacePage extends Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    info: PropTypes.object,
  };

  constructor(props) {
    super(props);
    this.state = {
      featureTop: new Animated.Value(0),
      actionTop: new Animated.Value(0),
      viewState: ViewState.HIDDEN,
    };
    this.state.featureTop.addListener(({ value }) => {
      this.featureTopValue = value;
    });
  }

  componentWillMount() {
    this.panResponder = new Utils.PanResponderWrapper({
      getStartValue: () => this.featureTopValue,
      onPanResponderMove: (evt, gestureState, startY) => {
        const newY = startY + gestureState.dy;
        this.state.featureTop.setValue(Math.max(newY, -this.height));
      },
      onPanResponderRelease: (evt, gestureState) => {
        if (this.state.viewState === ViewState.HEADER) {
          if (gestureState.vy < -0.01 || gestureState.dy < -10) { // swipe up or dragged 10px up
            this.expand();
          } else if (gestureState.vy > 0.01 || gestureState.dy > 10) { // swipe or dragged down
            this.popDown();
          } else {
            this.popToHeader();
          }
        } else if (this.state.viewState === ViewState.EXPANDED) {
          const directDropLimit = Utils.getScreenHeight() - 75;
          if (gestureState.moveY > directDropLimit) {
            this.popDown();
          } else if (gestureState.vy > 0.01 || gestureState.dy > 20) { // swipe or dragged down
            this.popToHeader();
          } else {
            this.expand();
          }
        }
      },
      onPanResponderTerminate: startY => this.state.featureTop.setValue(startY),
    });
  }

  componentWillReceiveProps(newProps) {
    if (newProps.info === null) {
      this.popDown();
    } else {
      this.popToHeader();
    }
  }

  popToHeader() {
    Utils.animateTo(this.state.featureTop, 150, -125);
    Utils.animateTo(this.state.actionTop, 150, -47);
    this.setState({ viewState: ViewState.HEADER });
  }

  popDown() {
    Utils.animateTo(this.state.featureTop, 100, 0);
    Utils.animateTo(this.state.actionTop, 100, 0);
    MWMMapView.deactivateMapSelection();
    this.setState({ viewState: ViewState.HIDDEN });
  }

  expand = () => {
    Utils.animateTo(this.state.featureTop, 150, -this.height);
    this.setState({ viewState: ViewState.EXPANDED });
  };

  headerClicked = () => {
    if (this.state.viewState === ViewState.HEADER) {
      this.expand();
    } else {
      this.popToHeader();
    }
  };

  render() {
    return (
      <View>
        <Animated.View
          style={[{ top: this.state.featureTop }, styles.featureContainer]}
          onLayout={(event) => {
            this.height = event.nativeEvent.layout.height;
          }}
        >
          <PlacePageInfo
            info={this.props.info} viewState={this.state.viewState}
            panHandlers={this.panResponder.panHandlers()} headerClicked={this.headerClicked}
          />
        </Animated.View>
        <Animated.View style={[{ top: this.state.actionTop }, styles.actionContainer]}>
          <ActionBar info={this.props.info} />
        </Animated.View>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  featureContainer: { position: 'absolute', left: 0, right: 0 },
  actionContainer: { position: 'absolute', left: 0, right: 0 },
});

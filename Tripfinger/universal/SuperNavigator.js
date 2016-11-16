import React from 'react';
import { NavigationExperimental, PixelRatio, StyleSheet } from 'react-native';
import CountriesScene from './guide/regions/CountriesScene';

const {
  CardStack: NavigationCardStack,
  StateUtils: NavigationStateUtils,
} = NavigationExperimental;

export default class NavigatorComponent extends React.Component {

  static propTypes = {
  };

  static idCounter = 0;

  constructor(props, context) {
    super(props, context);

    this.state = {
      navigationState: {
        index: 0, // Starts with first route focused.
        routes: [{
          key: String(NavigatorComponent.idCounter),
          component: CountriesScene,
          title: CountriesScene.title ? CountriesScene.title() : '',
        }],
      },
    };
    NavigatorComponent.idCounter += 1;
  }

  navigator = {
    push: ({ scene, props = {} }) => {
      NavigatorComponent.idCounter += 1;
      const title = scene.title ? scene.title(props) : '';
      const route = { key: String(NavigatorComponent.idCounter), component: scene, title, props };
      let { navigationState } = this.state;
      navigationState = NavigationStateUtils.push(navigationState, route);
      if (this.state.navigationState !== navigationState) {
        this.setState({ navigationState });
      }
    },
    pop: () => {
      let { navigationState } = this.state;
      navigationState = NavigationStateUtils.pop(navigationState);
      if (this.state.navigationState !== navigationState) {
        this.setState({ navigationState });
      }
    },
    jump: (sceneDicts) => {
      let { navigationState } = this.state;
      const routes = [];
      for (const sceneDict of sceneDicts) {
        NavigatorComponent.idCounter += 1;
        const title = sceneDict.scene.title ? sceneDicts.scene.title(sceneDicts.props) : '';
        const route = {
          key: String(NavigatorComponent.idCounter),
          component: sceneDict.scene,
          title,
          props: sceneDict.props,
        };
        routes.push(route);
      }
      navigationState = NavigationStateUtils.reset(navigationState, routes);
      if (this.state.navigationState !== navigationState) {
        this.setState({ navigationState });
      }
    },
  };

  _renderScene = (sceneProps) => {
    const Scene = sceneProps.scene.route.component;
    return (
      <Scene
        navigator={this.navigator}
        sceneProps={sceneProps}
        {...sceneProps.scene.route.props}
      />
    );
  };

  render() {
    return (
      <NavigationCardStack
        onNavigateBack={this._onPopRoute}
        navigationState={this.state.navigationState}
        renderScene={this._renderScene}
        style={styles.navigator}
      />
    );
  }
}

const styles = StyleSheet.create({
  navigator: {
    flex: 1,
  },
  scrollView: {
    marginTop: 64,
  },
  row: {
    padding: 15,
    backgroundColor: 'white',
    borderBottomWidth: 1 / PixelRatio.get(),
    borderBottomColor: '#CDCDCD',
  },
  rowText: {
    fontSize: 17,
  },
  buttonText: {
    fontSize: 17,
    fontWeight: '500',
  },
});

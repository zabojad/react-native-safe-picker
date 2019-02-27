/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *
 *
 * This is a controlled component version of RCTPickerIOS
 *
 * @format
 * @flow
 */

'use strict';

var React = require('react');
import { NativeModules, findNodeHandle, requireNativeComponent, processColor, ReactNative, StyleSheet, View } from 'react-native';

import type {SyntheticEvent} from 'CoreEventTypes';
import type {ColorValue} from 'StyleSheetTypes';
import type {ViewProps} from 'ViewPropTypes';
import type {TextStyleProp} from 'StyleSheet';

type SafePickerIOSChangeEvent = SyntheticEvent<
  $ReadOnly<{|
    newValue: any,
    newIndex: number,
  |}>,
>;

type RNSafePickerIOSItemType = $ReadOnly<{|
  label: ?Label,
  value: ?any,
  textColor: ?number,
|}>;

type RNSafePickerIOSType = Class<
  ReactNative.NativeComponent<
    $ReadOnly<{|
      items: $ReadOnlyArray<RNSafePickerIOSItemType>,
      onChange: (event: SafePickerIOSChangeEvent) => void,
      onResponderTerminationRequest: () => boolean,
      onStartShouldSetResponder: () => boolean,
      selectedIndex: number,
      style?: ?TextStyleProp,
    |}>,
  >,
>;

const RNSafePickerIOS: RNSafePickerIOSType = (requireNativeComponent(
  'RNSafePicker',
): any);

type Label = Stringish | number;

type Props = $ReadOnly<{|
  ...ViewProps,
  children: React.ChildrenArray<React.Element<typeof SafePickerIOSItem>>,
  itemStyle?: ?TextStyleProp,
  onChange?: ?(event: SafePickerIOSChangeEvent) => mixed,
  onValueChange?: ?(newValue: any, newIndex: number) => mixed,
  selectedValue: any,
|}>;

type State = {|
  selectedIndex: number,
  items: $ReadOnlyArray<RNSafePickerIOSItemType>,
|};

type ItemProps = $ReadOnly<{|
  label: ?Label,
  value?: ?any,
  color?: ?ColorValue,
|}>;

const SafePickerIOSItem = (props: ItemProps) => {
  return null;
};

class SafePickerIOS extends React.Component<Props, State> {
  _picker: ?React.ElementRef<RNSafePickerIOSType> = null;
  _pickerHandle = null;

  state = {
    selectedIndex: 0,
    items: [],
  };

  static Item = SafePickerIOSItem;

  isScrolling(){
    return NativeModules.RNSafePickerManager.isScrolling(this._pickerHandle);
  }
  isScrollingSynchronous(){
    return NativeModules.RNSafePickerManager.isScrollingSynchronous(this._pickerHandle);
  }

  static getDerivedStateFromProps(props: Props): State {
    let selectedIndex = 0;
    const items = [];
    React.Children.toArray(props.children).forEach(function(child, index) {
      if (child.props.value === props.selectedValue) {
        selectedIndex = index;
      }
      items.push({
        value: child.props.value,
        label: child.props.label,
        textColor: processColor(child.props.color),
      });
    });
    return {selectedIndex, items};
  }

  render() {
    return (
      <View style={this.props.style}>
        <RNSafePickerIOS
          ref={picker => {
            this._picker = picker;
            this._pickerHandle = findNodeHandle(picker);
          }}
          style={[styles.pickerIOS, this.props.itemStyle]}
          items={this.state.items}
          selectedIndex={this.state.selectedIndex}
          onChange={this._onChange}
          onStartShouldSetResponder={() => true}
          onResponderTerminationRequest={() => false}
        />
      </View>
    );
  }

  _onChange = event => {
    if (this.props.onChange) {
      this.props.onChange(event);
    }
    if (this.props.onValueChange) {
      this.props.onValueChange(
        event.nativeEvent.newValue,
        event.nativeEvent.newIndex,
      );
    }

    // The picker is a controlled component. This means we expect the
    // on*Change handlers to be in charge of updating our
    // `selectedValue` prop. That way they can also
    // disallow/undo/mutate the selection of certain values. In other
    // words, the embedder of this component should be the source of
    // truth, not the native component.
    if (
      this._picker &&
      this.state.selectedIndex !== event.nativeEvent.newIndex
    ) {
      this._picker.setNativeProps({
        selectedIndex: this.state.selectedIndex,
      });
    }
  };
}

const styles = StyleSheet.create({
  pickerIOS: {
    // The picker will conform to whatever width is given, but we do
    // have to set the component's height explicitly on the
    // surrounding view to ensure it gets rendered.
    height: 216,
  },
});

// module.exports = SafePickerIOS;

export default SafePickerIOS;

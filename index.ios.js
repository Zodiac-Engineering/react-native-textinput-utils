'use strict';

const React = require('react-native');

const {
  Component,
  TextInput,
  DeviceEventEmitter,
  View,
  Text,
  NativeModules: { KeyboardToolbar },
  processColor
} = React;

class RCTKeyboardToolbarHelper {
  static sharedInstance = new RCTKeyboardToolbarHelper();
  constructor() {
    this.counter = 0;
    this.callbackList = {};
  }
  static getUid() {
    return RCTKeyboardToolbarHelper.sharedInstance.counter++;
  }
  static setCallback(key, value) {
    RCTKeyboardToolbarHelper.sharedInstance.callbackList[key] = value;
  }
  static getCallback(key) {
    return RCTKeyboardToolbarHelper.sharedInstance.callbackList[key];
  }
}

DeviceEventEmitter.addListener(
  'keyboardToolbarDidTouchOnCancel', (currentUid) => {
    let eventHandler = RCTKeyboardToolbarHelper.getCallback(currentUid).onCancel;
    if (eventHandler) eventHandler();
  }
);

DeviceEventEmitter.addListener(
  'keyboardToolbarDidTouchOnDone', (currentUid) => {
    let eventHandler = RCTKeyboardToolbarHelper.getCallback(currentUid).onDone;
    if (eventHandler) eventHandler();
  }
);

DeviceEventEmitter.addListener(
  'keyboardPickerViewDidSelected', (data) => {
    console.log(`keyboardPickerViewDidSelected => data => ${data['selectedIndex']}`);
    var currentUid = data['currentUid'];
    var selectedIndex = data['selectedIndex'];
    let eventHandler = RCTKeyboardToolbarHelper.getCallback(currentUid).onPickerSelect;
    if (eventHandler) eventHandler(selectedIndex);
  }
);

DeviceEventEmitter.addListener(
  'keyboardDatePickerViewDidSelected', (data) => {
    console.log(`keyboardDatePickerViewDidSelected => data => ${data['selectedDate']}`);
    var currentUid = data['currentUid'];
    var selectedDate = new Date(data['selectedDate']);
    let eventHandler = RCTKeyboardToolbarHelper.getCallback(currentUid).onDatePickerSelect;
    if (eventHandler) eventHandler(selectedDate);
  }
);

class MyPicker extends Component {
  render() {
    return (
      <Text>11212</Text>
    );
  }
}

class RCTKeyboardToolbarManager {
  static configure(node, options, callbacks) {
    var reactNode = React.findNodeHandle(node);
    options.uid = RCTKeyboardToolbarHelper.getUid();
    let test = new MyPicker;
    KeyboardToolbar.configure(reactNode, options, (error, currentUid) => {
      if (!error) {
        RCTKeyboardToolbarHelper.setCallback(currentUid, {
          onCancel: callbacks.onCancel,
          onDone: callbacks.onDone,
          onPickerSelect: callbacks.onPickerSelect,
          onDatePickerSelect: callbacks.onDatePickerSelect,
        });
      }
    });
  }
  static dismissKeyboard(node) {
    var nodeHandle = React.findNodeHandle(node);
    KeyboardToolbar.dismissKeyboard(nodeHandle);
  }
  static moveCursorToLast(node) {
    var nodeHandle = React.findNodeHandle(node);
    KeyboardToolbar.moveCursorToLast(nodeHandle);
  }
  static setSelectedTextRange(node, NSRange) {
    var nodeHandle = React.findNodeHandle(node);
    KeyboardToolbar.setSelectedTextRange(nodeHandle, NSRange);
  }
   static setDate(node, NSDate) {
    var nodeHandle = React.findNodeHandle(node);
    KeyboardToolbar.setDate(nodeHandle, NSDate);
  }
  static setPickerRowByIndex(node, NSInteger) {
    var nodeHandle = React.findNodeHandle(node);
    KeyboardToolbar.setPickerRowByIndex(nodeHandle, NSInteger);
  }
    static reloadPickerData(node, NSArray) {
    var nodeHandle = React.findNodeHandle(node);
    KeyboardToolbar.reloadPickerData(nodeHandle, NSArray);
  }

}

class RCTKeyboardToolbarTextInput extends Component {
  componentDidMount() {
    var pickerViewData = [];
    if (this.props.pickerViewData) {
      this.props.pickerViewData.map((eachData) => {
        pickerViewData.push(eachData.label);
      });
    }

    var callbacks = {
      onCancel: () => {
        // onCancel
        if (this.props.onCancel) this.props.onCancel(RCTKeyboardToolbarManager.dismissKeyboard.bind(this, this.refs['MygKD']));
      },
      onDone: () => {
        // onDone
        if (this.props.onDone) this.props.onDone(RCTKeyboardToolbarManager.dismissKeyboard.bind(this, this.refs['MygKD']));
      },
      onPickerSelect: this.props.onPickerSelect,
      onDatePickerSelect: this.props.onDatePickerSelect
    };

    RCTKeyboardToolbarManager.configure(this.refs['MygKD'], {
      barStyle: this.props.barStyle,
      leftButtonText: this.props.leftButtonText,
      rightButtonText: this.props.rightButtonText,
      pickerViewData: pickerViewData,
      datePicker: 'datePicker' in this.props ? this.props.datePicker : false,
      datePickerMode: this.props.datePickerMode,
      borderBottom: this.props.borderBottom,
      tintColor: processColor(this.props.tintColor)
    }, callbacks);
  }
  dismissKeyboard() {
    RCTKeyboardToolbarManager.dismissKeyboard(this.refs['MygKD']);
  }
  moveCursorToLast() {
    RCTKeyboardToolbarManager.moveCursorToLast(this.refs['MygKD']);
  }
  setSelection(start, length) {
    RCTKeyboardToolbarManager.setSelectedTextRange(this.refs['MygKD'], {
      start: start,
      length: length
    });
  }
  setDate(date) {
    RCTKeyboardToolbarManager.setDate(this.refs['MygKD'], {
      date: date
    });
  }
  setPickerRowByIndex(index) {
    RCTKeyboardToolbarManager.setPickerRowByIndex(this.refs['MygKD'], {
      index: index
    });
  }
  reloadPickerData(data) {
     data = data.map((eachData) => {
        return eachData.label;
      });
    RCTKeyboardToolbarManager.reloadPickerData(this.refs['MygKD'], {
      data
    });
  }
  render() {
    return (
      <TextInput
        {...this.props}
        ref='MygKD'/>
    );
  }
}

module.exports = RCTKeyboardToolbarTextInput;

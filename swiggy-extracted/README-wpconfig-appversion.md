> Appversion specific WP Config

*Problem to solve*

1. Ability to send different wp config for different app version
2. Also avoid duplicate configs in wp response for every app version and avoid logic to pick the closest appversion for each key
3. Differentiate whether config is sent as default value or app specific value

*Solution*

For keys to be differentiated based on app version, value can be sent as json string as shown below
```
    {
        aEnabled: true  // normal key without app version differentiation
        bEnabled:{
            version: 378,
            value: true,
            default: false
        } // key with app differentiation
    }
```

- All the json which has `version` and `value` fields as non empty value will be considered as WPObject and value sent in `value` field will be considered for apps with appversion greater or equal than the intValue of value sent in `version` field
- For apps with app version less than the value sent in `version`, value sent in default will be picked
- As Default is optional field, in cases where `default` field is not sent, value will be picked from default value provided in `SettingsService` dictionary






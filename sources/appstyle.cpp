#include "headers/appstyle.h"

AppStyle::AppStyle(QObject *parent) : QObject(parent)
{
    QVariantMap tmpDarkTheme = {
        {"backgroundColor", "#2d3037"},

        {"buttonColor", "#202227"},
        {"buttonPressedColor", "#6ccaf2"},
        {"buttonBorderColor", "grey"},
        {"disabledButtonColor", "#555555"},

        {"viewColor", "#202227"},
        {"menuColor", "#292b32"},

        {"delegate1Color", "#202227"},
        {"delegate2Color", "#202227"},

        {"textColor", "#ffffff"},
        {"textDarkColor", "#232323"},
        {"disabledTextColor", "#777777"},

        {"sliderColor", "#6ccaf2"},

        {"errorColor", "#ba3f62"},
        {"infoColor", "#3fba62"},

        {"lineColor", "grey"},

        {"backIcon", "qrc:/icons/back.png"},
        {"settingsIcon", "qrc:/icons/settings.png"},
        {"treffpunktFannyIcon", "qrc:/graphics/images/TreffpunktFannyLogoLight.png"},
        {"fannyLogo", "qrc:/graphics/images/FannyLogoLight.png"},

        {"nameMaterialStyle", "Dark"}

    };
    this->darkTheme = tmpDarkTheme;

    QVariantMap tmpLightTheme = {
        {"backgroundColor", "white"},

        {"buttonColor", "white"},
        {"buttonPressedColor", "lightgrey"},
        {"buttonBorderColor", "grey"},
        {"disabledButtonColor", "#d5d5d5"},

        {"viewColor", "white"},
        {"menuColor", "#f8f8f8"},

        {"delegate1Color", "#202227"},
        {"delegate2Color", "#202227"},

        {"textColor", "black"},
        {"textDarkColor", "#232323"},
        {"disabledTextColor", "grey"},

        {"sliderColor", "#6ccaf2"},

        {"errorColor", "#ba3f62"},
        {"infoColor", "#3fba62"},

        {"lineColor", "grey"},

        {"backIcon", "qrc:/icons/backDark.png"},
        {"settingsIcon", "qrc:/icons/settingsBlack.png"},
        {"treffpunktFannyIcon", "qrc:/graphics/images/TreffpunktFannyLogoDark.png"},
        {"fannyLogo", "qrc:/graphics/images/FannyLogoDark.jpg"}

    };
    this->lightTheme = tmpLightTheme;

    QString currentThemeString = pGlobalAppSettings->loadSetting("theme");

    if(currentThemeString == "Light"){
        this->currentTheme = &this->lightTheme;
    }
    else if (currentThemeString == "Dark") {
        this->currentTheme = &this->darkTheme;
    }
    else {
        this->currentTheme = &this->lightTheme;
    }
}

QVariant AppStyle::getStyle() {
    return *this->currentTheme;
}

void AppStyle::changeTheme() {
    QString currentThemeString = pGlobalAppSettings->loadSetting("theme");
    QString newThemeString = "Light";

    if(currentThemeString == "Light"){
        this->currentTheme = &this->darkTheme;
        newThemeString = "Dark";

    }
    else if (currentThemeString == "Dark") {
        this->currentTheme = &this->lightTheme;
        newThemeString = "Light";
    }
    else {
        this->currentTheme = &this->lightTheme;
    }

    pGlobalAppSettings->writeSetting("theme", newThemeString);

    emit this->styleChanged();
}

void AppStyle::refreshTheme() {
    QString currentThemeString = pGlobalAppSettings->loadSetting("theme");

    if(currentThemeString == "Light"){
        this->currentTheme = &this->lightTheme;
    }
    else if (currentThemeString == "Dark") {
        this->currentTheme = &this->darkTheme;
    }

    emit this->styleChanged();
}

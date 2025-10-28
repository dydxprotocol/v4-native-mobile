import React, { use, useEffect, useState } from 'react';
import {
  View,
  TouchableOpacity,
  ScrollView,
  DeviceEventEmitter,
  Modal,
  ActivityIndicator,
} from 'react-native';
import { Button } from "./ui/button";
import { Text } from './ui/text';
import { TurnkeyConfigs } from '../sharedConfigs';
import { useAuthRelay } from '../hooks/useAuthRelay';
import { OAuthInput } from './OAuthInput';
import { EmailInput } from './EmailInput';
import { useThemedStyles } from '../turnkeyStyle';
import { LoginMethod } from '../lib/types';
import { DydxAddressReceivedEvent, EmailTokenReceivedEvent, TurnkeyNativeModule } from '../../TurnkeyModule';
import { useEmbeddedKeyAndNonce } from './useEmbeddedKeyAndNonce';
import { Image } from 'react-native';
import { currentTheme } from '../../rn_style/themes/currentTheme';
import { DydxTurnkeySession } from '../providers/dydxTurnkeySession';
import RenderHTML from "react-native-render-html";
import { useWindowDimensions } from "react-native";
import { useLocalizedString } from '../../useLocalizedString';

const renderError = () => {
  const {
    state,
  } = useAuthRelay();

  if (state.error !== "" && state.loading === null) {
    return (
      <Text style={{ color: currentTheme.colors.red, marginBottom: 20, textAlign: 'center' }}>
        {state.error}
      </Text>
    );
  }
  return null;
}

export const Auth = ({ configs }: { configs: TurnkeyConfigs }) => {
  const {
    loginWithOAuth,
    loginWithAppleAuth,
    uploadDydxAddress,
    completeOtpAuth,
  } = useAuthRelay();
  const [continueModal, setContinueModal] = useState(false);
  const [continueModalProviderName, setContinueModalProviderName] = useState<string>();

  const oAuthEmbeddedKeyAndNonce = useEmbeddedKeyAndNonce(LoginMethod.OAuth);
  const emailEmbeddedKeyAndNonce = useEmbeddedKeyAndNonce(LoginMethod.Email);

  useEffect(() => {
    DeviceEventEmitter.removeAllListeners('EmailTokenReceived');
    DeviceEventEmitter.addListener(
      'EmailTokenReceived',
      async ({ token }: EmailTokenReceivedEvent) => {
        setContinueModalProviderName("Email");
        setContinueModal(true);
        const session = await completeOtpAuth({
          otpType: "email",
          token: token,
          configs: configs,
        });

        registerDydxAddressReceivedHandler(session);

        await emailEmbeddedKeyAndNonce.refreshNonce();
      }
    );
  }, [emailEmbeddedKeyAndNonce]);

  function registerDydxAddressReceivedHandler(session: DydxTurnkeySession | undefined) {
    DeviceEventEmitter.removeAllListeners('DydxAddressReceived');
    DeviceEventEmitter.addListener(
      'DydxAddressReceived',
      async ({ callbackId, dydxAddress }: DydxAddressReceivedEvent) => {
        if (!session) {
          console.error("No DYDX session available");
          TurnkeyNativeModule.onJsResponse(callbackId, "failed: No DYDX session available");
          return;
        }

        try {
          await uploadDydxAddress({
            dydxSession: session,
            dydxAddress: dydxAddress,
            configs: configs,
          })
          TurnkeyNativeModule.onJsResponse(callbackId, "success");
        } catch (error) {
          console.error("Error uploading dydx address:", error);
          TurnkeyNativeModule.onJsResponse(callbackId, "failed: " + error);
        } finally {
          setContinueModal(false);
          setContinueModalProviderName(undefined);
        }
      }
    );
  }

  const styles = useThemedStyles(currentTheme);

  const [isEmailFocused, setIsEmailFocused] = useState(false);

  const { state } = useAuthRelay();
  const hasError = state.error !== "" && state.loading === null;
  const showContinueModal = continueModal && hasError === false;

  const { width } = useWindowDimensions();

  const tos =  useLocalizedString("APP.HEADER.TERMS_OF_USE");
  const tosLink = `<a href="${configs.tosUrl}">${tos}</a>`;
  const privacy = useLocalizedString("APP.ONBOARDING.PRIVACY_POLICY");
  const privacyLink = `<a href="${configs.privacyUrl}">${privacy}</a>`;

  const tosText = useLocalizedString("APP.ONBOARDING.TOS_SHORT", {
    "TERMS_LINK": tosLink,
    "PRIVACY_POLICY_LINK": privacyLink,
  }) ?? "";
  const tosHtml = {
    html: tosText
  };

  const MemoizedRenderHTML = React.memo(RenderHTML);

  const signInTitle = useLocalizedString("APP.TURNKEY_ONBOARD.SIGN_IN_TITLE");
  const signInDescription = useLocalizedString("APP.TURNKEY_ONBOARD.SIGN_IN_DESCRIPTION");
  const orText = useLocalizedString("APP.GENERAL.OR") ?? "Or";
  const signInDesktopText = useLocalizedString("APP.TURNKEY_ONBOARD.SIGN_IN_DESKTOP");
  const signInWalletText = useLocalizedString("APP.TURNKEY_ONBOARD.SIGN_IN_WALLET");

  return (
    <ScrollView
      bounces={false} // iOS
      overScrollMode="never" // Android
      contentContainerStyle={styles.container}
    >
      <View style={styles.content}>
        <ContinueSignInModal
          visible={showContinueModal}
          onClose={() => setContinueModal(false)}
          configs={configs}
          currentTheme={currentTheme}
          styles={styles}
          providerName={continueModalProviderName}
        />

        <View>
          {/* Draggable indicator bar */}
          <View style={styles.dragHandle} />

          {/* Header */}
          <Text style={styles.title}>{signInTitle}</Text>
          <Text style={styles.subtitle}>
            {signInDescription}
          </Text>

          {/* Social icons row */}
          <View style={styles.socialRow}>
            <OAuthInput
              onSuccess={async (params) => {
                setContinueModalProviderName(params.providerName);
                setContinueModal(true);
                const session = await loginWithOAuth(params);
                registerDydxAddressReceivedHandler(session);
              }}
              onAppleAuthSuccess={ async (params) => {
                setContinueModalProviderName(params.providerName);
                setContinueModal(true);
                const session = await loginWithAppleAuth(params);
                registerDydxAddressReceivedHandler(session);
              }}
              configs={configs}
              embeddedKeyAndNonce={oAuthEmbeddedKeyAndNonce} />
          </View>

          {/* Email input row */}
          <View style={[styles.emailRow, { borderColor: isEmailFocused ? currentTheme.colors.purple : currentTheme.colors.layer4 }]}>
            <EmailInput
              embeddedKeyAndNonce={emailEmbeddedKeyAndNonce}
              configs={configs}
              focusChanged={(focused) => {
                setIsEmailFocused(focused)
              }}
            />
          </View>

          {renderError()}

        </View>

        <View>

          {/* Divider */}
          <View style={styles.dividerContainer}>
            <View style={styles.divider} />
            <Text style={styles.dividerText}>{orText}</Text>
            <View style={styles.divider} />
          </View>

          {/* Sign in with Passkey */}
          {/* <TouchableOpacity style={styles.actionButton}>
          <Ionicons
            name="person"
            size={18}
            color="#fff"
            style={{ marginRight: 8 }}
          />
          <Text style={styles.actionButtonText}>Sign in with Passkey</Text>
        </TouchableOpacity> */}

          {/* Sign in with Desktop */}
          <TouchableOpacity
            style={styles.actionButton}
            onPress={async () => {
              TurnkeyNativeModule.onAuthRouteToDesktopQR();
            }}>
            <Image
              source={require('../../rn_style/assets/icon_desktop.png')}
              style={{ width: 18, height: 18, marginEnd: 8, tintColor: currentTheme.colors.textSecondary }}
            />
            <Text style={styles.actionButtonText}>{signInDesktopText}</Text>
            <Image
              source={require('../../rn_style/assets/chevron_right.png')}
              style={{ height: 10, tintColor: currentTheme.colors.textTertiary }}
              resizeMode="contain"
            />
          </TouchableOpacity>

          {/* Sign in with Wallet */}
          <TouchableOpacity
            style={styles.actionButton}
            onPress={async () => {
              TurnkeyNativeModule.onAuthRouteToWallet();
            }}>
            <Image
              source={require('../../rn_style/assets/icon_wallet.png')}
              style={{ width: 16, height: 16, marginEnd: 8, tintColor: currentTheme.colors.textSecondary }}
            />
            <Text style={styles.actionButtonText}>{signInWalletText}</Text>
            <Image
              source={require('../../rn_style/assets/chevron_right.png')}
              style={{ height: 10, tintColor: currentTheme.colors.textTertiary }}
              resizeMode="contain"
            />
          </TouchableOpacity>

          <MemoizedRenderHTML
            contentWidth={width * 0.9} // 90% of screen width
            source={tosHtml}
            baseStyle={{ textAlign: "center", paddingBottom: 20 }} // center text inside

            tagsStyles={{
              body: { fontFamily: "Satoshi-Regular", fontSize: 11, color: currentTheme.colors.textTertiary },
              a: { color: currentTheme.colors.purple }, // links color
            }}
          />

        </View>
      </View>
    </ScrollView>
  );
}

type ContinueSignInModalProps = {
  visible: boolean;
  onClose: () => void;
  configs: any; // Replace with proper type
  currentTheme: any; // Replace with proper type
  styles: any;
  providerName: any;
};

const iconMap: Record<string, any> = {
  email: require('../../rn_style/assets/icon_mail2.png'),
  apple: require('../../rn_style/assets/logo_apple.png'),
  google: require('../../rn_style/assets/logo_google.png'),
};

const ContinueSignInModal = ({
  visible,
  onClose,
  configs,
  currentTheme,
  styles,
  providerName,
}: ContinueSignInModalProps) => {
  var signInTitle: string | null = null;
  switch (providerName?.toLowerCase()) {
    case "google":
      signInTitle = useLocalizedString('APP.TURNKEY_ONBOARD.SIGN_IN_GOOGLE');
      break;
    case "apple":
      signInTitle = useLocalizedString('APP.TURNKEY_ONBOARD.SIGN_IN_APPLE');
      break;
    case "email": 
      signInTitle = useLocalizedString('APP.TURNKEY_ONBOARD.SIGN_IN_EMAIL');
      break;
    default:
      signInTitle = useLocalizedString('APP.TURNKEY_ONBOARD.CONTINUE_SIGN_IN_TITLE');
  }
  return (
    <Modal
      visible={visible}
      animationType="slide"
      onRequestClose={onClose}
      transparent={false} // full overlay
    >
      <View
        style={{
          flex: 1,
          backgroundColor: currentTheme.colors.layer1,
          justifyContent: 'center',
          alignItems: 'center',
        }}
      >
        {/* Close button in top-right */}
        <View style={{ position: 'absolute', top: 40, right: 20 }}>
          <Button onPress={onClose}>
            <Image
              source={require('../../rn_style/assets/x-mark.png')}
              style={{
                width: 24,
                height: 24,
                tintColor: currentTheme.colors.textSecondary,
              }}
            />
          </Button>
        </View>

        {/* Your overlay content */}
        <ActivityIndicator size={32} color={currentTheme.colors.purple} />

        <Text
          style={{
            fontSize: currentTheme.fontSizes.medium,
            color: currentTheme.colors.textPrimary,
            marginBottom: 8,
          }}
        >{signInTitle}
        </Text>

        <Text
          style={{
            fontSize: currentTheme.fontSizes.small,
            color: currentTheme.colors.textTertiary,
            textAlign: 'center',
            paddingHorizontal: 24,
          }}
        >
          {useLocalizedString('APP.TURNKEY_ONBOARD.CONTINUE_SIGN_IN_DESCRIPTION')}
        </Text>
      </View>
    </Modal>
  );
};

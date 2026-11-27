/* -*- Mode: Java; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */
/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Published in quiredocs-engine (android-bridge/QuireLOBridge.java).
 */

package org.libreoffice.androidlib;

/**
 * Quire Docs (not an upstream file): reuses LOActivity's JNI bridge without running LOActivity as an Activity.
 *
 * androidapp.cpp binds its natives to {@code Java_org_libreoffice_androidlib_LOActivity_*} and calls back
 * {@code rawCallFakeWebsocketOnMessage([B)V} / {@code postMobileMessage(String)} on the instance passed to
 * createCOOLWSD (looked up via GetObjectClass, so overrides win). This subclass is constructed but never
 * attached or started; both callbacks go to {@link Listener}. It lives in this package because
 * rawCallFakeWebsocketOnMessage is package-private. Construct it on the main thread (ComponentActivity's
 * constructor registers lifecycle observers).
 */
public final class QuireLOBridge extends LOActivity {
    public interface Listener {
        /** Core → frontend message (called on the native app2js thread). */
        void onCoreMessage(byte[] message);

        /** Message for the host (posted by native code via postDirectMessage). */
        void onHostMessage(String message);
    }

    private volatile Listener listener;

    public void setListener(Listener listener) {
        this.listener = listener;
    }

    @Override
    void rawCallFakeWebsocketOnMessage(byte[] message) {
        Listener l = listener;
        if (l != null) l.onCoreMessage(message);
    }

    @Override
    public void postMobileMessage(String message) {
        Listener l = listener;
        if (l != null) l.onHostMessage(message);
    }
}

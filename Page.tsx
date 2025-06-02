"use client";

import {
  useAuthModal,
  useLogout,
  useSigner,
  useSignerStatus,
  useUser,
} from "@account-kit/react";
import { useEffect, useState } from "react";

interface ApiKeyResponse {
  publicKey: string;
}

export default function Home() {
  const user = useUser();
  const { openAuthModal } = useAuthModal();
  const signerStatus = useSignerStatus();
  const { logout } = useLogout();
  const signer = useSigner();

  const [createdApiKey, setCreatedApiKey] = useState(false);
  const [isCreating, setIsCreating] = useState(false);

  // Автоматическое создание API-ключа при наличии всех условий
  useEffect(() => {
    if (!user && createdApiKey) {
      setCreatedApiKey(false);
    }

    if (
      !user ||
      !signer ||
      !signerStatus.isConnected ||
      createdApiKey ||
      isCreating
    ) {
      return;
    }

    let isMounted = true;

    const submitStamp = async (): Promise<ApiKeyResponse> => {
      const whoamiStamp = await signer.inner.stampWhoami();
      const resp = await fetch("/api/get-api-key", {
        method: "POST",
        body: JSON.stringify({ whoamiStamp }),
      });
      if (!resp.ok) {
        throw new Error("Failed to fetch public key");
      }
      return await resp.json();
    };

    const createApiKey = async (publicKey: string): Promise<void> => {
      await signer.inner.experimental_createApiKey({
        name: `server-signer-${Date.now()}`,
        publicKey,
        expirationSec: 60 * 60 * 24 * 62, // 62 дня
      });
    };

    const handleAll = async () => {
      setIsCreating(true);
      try {
        const { publicKey } = await submitStamp();
        await createApiKey(publicKey);
        await fetch("/api/set-api-key-activated", {
          method: "POST",
          body: JSON.stringify({ orgId: user.orgId, apiKey: publicKey }),
        });
        if (isMounted) {
          setCreatedApiKey(true);
        }
      } catch (err) {
        console.error(err);
        alert("Произошла ошибка. Подробности в консоли.");
      } finally {
        if (isMounted) setIsCreating(false);
      }
    };

    handleAll();

    return () => {
      isMounted = false;
    };
  }, [createdApiKey, signer, signerStatus.isConnected, user, isCreating]);

  // Проверка на наличие крипто API
  useEffect(() => {
    if (typeof window === "undefined") return;

    try {
      if (typeof window.crypto.subtle !== "object") {
        throw new Error("window.crypto.subtle is not available");
      }
    } catch (err) {
      alert(
        "Crypto API недоступен в этом браузере. Используйте HTTPS или localhost."
      );
    }
  }, []);

  // Автооткрытие модального окна авторизации
  useEffect(() => {
    if (!user && !signerStatus.isInitializing) {
      openAuthModal();
    }
  }, [user, signerStatus.isInitializing]);

  return (
    <main className="flex min-h-screen flex-col items-center gap-4 justify-center text-center">
      {signerStatus.isInitializing || (user && !createdApiKey) ? (
        <>Loading...</>
      ) : user ? (
        <div className="card">
          <div className="flex flex-col gap-2 p-2">
            <p className="text-xl font-bold">
              ВЫ УСПЕШНО ВОШЛИ В GENSYN TESTNET
            </p>
            <button className="btn btn-primary mt-6" onClick={logout}>
              Выйти
            </button>
          </div>
        </div>
      ) : (
        <div className="card">
          <p className="text-xl font-bold">ВОЙДИТЕ В GENSYN TESTNET</p>
          <div className="flex flex-col gap-2 p-2">
            <button className="btn btn-primary mt-6" onClick={openAuthModal}>
              Войти
            </button>
          </div>
        </div>
      )}
    </main>
  );
}

import { createApp } from 'vue';
import { createPinia } from 'pinia';
import PrimeVue from 'primevue/config';
import Aura from '@primevue/themes/aura';
import ToastService from 'primevue/toastservice';
import ConfirmationService from 'primevue/confirmationservice';

import 'primeicons/primeicons.css';
import '@tabler/icons-webfont/dist/tabler-icons.min.css';
import './styles/global.css';

import App from './App.vue';
import router from './router';
import { setupInterceptor } from './api/interceptor';
import { initKeycloak } from './keycloak';
import { useAuthStore } from './store/auth';

async function bootstrap() {
  const app = createApp(App);
  const pinia = createPinia();
  app.use(pinia);
  app.use(router);
  app.use(PrimeVue, {
    theme: { preset: Aura, options: { darkModeSelector: '.dark' } }
  });
  app.use(ToastService);
  app.use(ConfirmationService);

  setupInterceptor(router);

  try {
    const kc = await initKeycloak();
    const auth = useAuthStore();
    if (kc.authenticated) {
      auth.accessToken = kc.token || null;
      await auth.loadUserInfo();
    }
  } catch (e) {
    console.warn('Keycloak init failed — starting unauthenticated', e);
  }

  app.mount('#app');
}

bootstrap();

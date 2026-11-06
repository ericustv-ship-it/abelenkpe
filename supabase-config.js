/*
  Shared Supabase configuration for the Abelenkpe SDA Church Attendance System.
  Place this file in the same folder as the HTML pages that load it.
  This file initializes the client only; database tables and policies will be
  configured after all frontend pages have been prepared.
*/
(function () {
  const SUPABASE_URL = "https://jyaacjphbqhoafiprkhg.supabase.co";
  const SUPABASE_PUBLISHABLE_KEY = "sb_publishable_4ZZI7mvJuhXjRRpTpD24Dw_4KRiUutD";

  if (!window.supabase || typeof window.supabase.createClient !== "function") {
    console.error("Supabase library failed to load. Check your internet connection.");
    window.supabaseClient = null;
    window.supabaseReady = false;
    return;
  }

  if (!window.supabaseClient) {
    window.supabaseClient = window.supabase.createClient(
      SUPABASE_URL,
      SUPABASE_PUBLISHABLE_KEY
    );
  }

  window.supabaseReady = true;
  console.log("Shared Supabase client initialized.");
})();

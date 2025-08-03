//
//  SupabaseClient.swift
//  Level Up
//
//  Created by Jake Gray on 8/3/25.
//

import SwiftUI
import Supabase

let client = SupabaseClient(
    supabaseURL: URL(string: "https://uprgcseatwhpptlmmdjr.supabase.co")!,
    supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVwcmdjc2VhdHdocHB0bG1tZGpyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIwNzM4NzEsImV4cCI6MjA2NzY0OTg3MX0.D7_ahKtqoYAmfuHs4YX50yQhIkHmX1ChAYvfaD-cqfg"
)

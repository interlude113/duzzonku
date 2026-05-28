<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('expenses', function (Blueprint $table) {
            $table->id();
            // どの旅行の支出かを紐付け
            $table->foreignId('trip_id')->constrained()->onDelete('cascade');
            // 支出金額
            $table->integer('amount');
            // カテゴリ（例：食費・交通・宿泊）
            $table->string('category');
            // メモ（任意入力）
            $table->string('memo')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('expenses');
    }
};
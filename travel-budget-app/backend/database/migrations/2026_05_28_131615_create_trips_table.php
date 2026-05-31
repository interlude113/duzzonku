<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('trips', function (Blueprint $table) {
            $table->id();
            // ログインユーザーとの紐付け
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            // 旅行名（例：大阪旅行）
            $table->string('name');
            // 旅行の予算
            $table->integer('budget');
            // 旅行の開始日・終了日
            $table->date('start_date');
            $table->date('end_date');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('trips');
    }
};
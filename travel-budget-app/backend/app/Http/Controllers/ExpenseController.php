<?php

namespace App\Http\Controllers;

use App\Models\Trip;
use App\Models\Expense;
use Illuminate\Http\Request;

class ExpenseController extends Controller
{
    // 指定した旅行の支出一覧と合計を取得
    public function index(Trip $trip)
    {
        // 他のユーザーの旅行にはアクセスできないように制限
        if ($trip->user_id !== auth()->id()) {
            return response()->json(['message' => '権限がありません'], 403);
        }

        $expenses = $trip->expenses()->latest()->get();

        // 合計金額を計算
        $total = $expenses->sum('amount');

        // 残高 = 予算 - 合計支出
        $balance = $trip->budget - $total;

        return response()->json([
            'expenses' => $expenses,
            'total' => $total,
            'balance' => $balance,
        ]);
    }

    // 支出を新規登録
    public function store(Request $request, Trip $trip)
    {
        // 他のユーザーの旅行には追加できないように制限
        if ($trip->user_id !== auth()->id()) {
            return response()->json(['message' => '権限がありません'], 403);
        }

        // 入力値のバリデーション
        $request->validate([
            'amount' => 'required|integer',
            'category' => 'required|string',
            'memo' => 'nullable|string',
        ]);

        $expense = $trip->expenses()->create($request->all());

        return response()->json($expense, 201);
    }

    // 支出を削除
    public function destroy(Trip $trip, Expense $expense)
    {
        // 他のユーザーの旅行の支出は削除できないように制限
        if ($trip->user_id !== auth()->id()) {
            return response()->json(['message' => '権限がありません'], 403);
        }

        $expense->delete();

        return response()->json(['message' => '削除しました']);
    }
}
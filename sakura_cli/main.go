package main

import (
	"fmt"
	"math/rand"
	"os"
	"strings"
	"time"

	tea "github.com/charmbracelet/bubbletea"
)

// 1. Model: 桜の花びらの位置と速度を表す構造体
type petal struct {
	x, y  int
	speed int
}

type model struct {
	width, height int
	petals        []petal
}

// 초기화: 桜の葉っぱをランダムに配置
func initialModel() model {
	m := model{petals: make([]petal, 30)}
	for i := range m.petals {
		m.petals[i] = petal{
			x:     rand.Intn(100),
			y:     rand.Intn(30),
			speed: rand.Intn(2) + 1,
		}
	}
	return m
}

// 2. Update: 時間に応じて位置の変化を計算
type tickMsg time.Time

func tick() tea.Cmd {
	return tea.Tick(time.Millisecond*100, func(t time.Time) tea.Msg {
		return tickMsg(t)
	})
}

func (m model) Init() tea.Cmd {
	return tick() // スタートと同時に最初のティックを予約
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg: // テルミナルのサイズが変わったとき
		m.width, m.height = msg.Width, msg.Height
	case tickMsg: // 0.1초마다 실행되는 로직
		for i := range m.petals {
			m.petals[i].y += m.petals[i].speed // 下に移動
			m.petals[i].x += rand.Intn(3) - 1  // 風に揺れる (-1, 0, 1)

			// バットに当たったらまた上に
			if m.petals[i].y >= m.height {
				m.petals[i].y = 0
				m.petals[i].x = rand.Intn(m.width)
			}
		}
		return m, tick() // 次のティックを予約
	case tea.KeyMsg: // 'q'キーまたはCtrl+Cで終了
		if msg.String() == "q" || msg.String() == "ctrl+c" {
			return m, tea.Quit
		}
	}
	return m, nil
}

// 3. View: 桜の花びらをターミナルに描画
func (m model) View() string {
	// 空の画面を作成
	screen := make([][]string, m.height)
	for i := range screen {
		screen[i] = make([]string, m.width)
		for j := range screen[i] {
			screen[i][j] = " "
		}
	}

	// 花びらを画面に配置
	for _, p := range m.petals {
		if p.y < m.height && p.x >= 0 && p.x < m.width {
			screen[p.y][p.x] = ""
		}
	}

	// 画面を文字列に変換
	var b strings.Builder
	for _, row := range screen {
		b.WriteString(strings.Join(row, ""))
		b.WriteString("\n")
	}
	b.WriteString("\n  Press 'q' to quit.")
	return b.String()
}

func main() {
	p := tea.NewProgram(initialModel(), tea.WithAltScreen())
	if _, err := p.Run(); err != nil {
		fmt.Printf("Error occurred: %v", err)
		os.Exit(1)
	}
}
